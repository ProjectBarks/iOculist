//
//  FindDistanceVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "FindDistanceVC.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
@interface FindDistanceVC ()

@property (nonatomic) BOOL isUsingFrontFacingCamera;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIImage *borderImage;
@property (nonatomic, strong) CIDetector *faceDetector;


- (void)setupAVCapture;
- (void)teardownAVCapture;
- (void)drawFaces:(NSArray *)features
      forVideoBox:(CGRect)videoBox
      orientation:(UIDeviceOrientation)orientation;

@end

@implementation FindDistanceVC

@synthesize videoDataOutput = _videoDataOutput;
@synthesize videoDataOutputQueue = _videoDataOutputQueue;

@synthesize borderImage = _borderImage;
@synthesize previewView = _previewView;
@synthesize previewLayer = _previewLayer;

@synthesize faceDetector = _faceDetector;

@synthesize isUsingFrontFacingCamera = _isUsingFrontFacingCamera;

@synthesize player;
float rightEyeX = -100000.00;
float leftEyeX = -100000.00;
float rightEyeY = -100000.00;
float leftEyeY = -100000.00;
int frameDelay = 1;
int counter = 0;
BOOL executed = NO;

- (void)setupAVCapture
{
	NSError *error = nil;
	
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	} else {
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	}
    
    // Select a video device, make an input
	AVCaptureDevice *device;
	
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
	
    // find the front facing camera
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			device = d;
            self.isUsingFrontFacingCamera = YES;
			break;
		}
	}
    // fall back to the default camera.
    if( nil == device )
    {
        self.isUsingFrontFacingCamera = NO;
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // get the input device
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
	if( !error ) {
        
        // add the input to the session
        if ( [session canAddInput:deviceInput] ){
            [session addInput:deviceInput];
        }
        // Make a video data output
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                           [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked
        
        // create a serial dispatch queue used for the sample buffer delegate
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
        
        if ( [session canAddOutput:self.videoDataOutput] ){
            [session addOutput:self.videoDataOutput];
        }
        
        // get the output for doing face detection.
        [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        self.previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        CALayer *rootLayer = [self.previewView layer];
        [rootLayer setMasksToBounds:YES];
        [self.previewLayer setFrame:[rootLayer bounds]];
        [rootLayer addSublayer:self.previewLayer];
        [session startRunning];
        
    }
	session = nil;
	if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                                  [NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
		[alertView show];
		[self teardownAVCapture];
	}
}

// clean up capture setup
- (void)teardownAVCapture
{
	self.videoDataOutput = nil;
	[self.previewLayer removeFromSuperlayer];
	self.previewLayer = nil;
}


// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
                                  message:[error localizedDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil];
        [alertView show];
	});
}


// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity
                          frameSize:(CGSize)frameSize
                       apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector
// to detect features and for each draw the green border in a layer and set appropriate orientation
- (void)drawFaces:(NSArray *)features
      forVideoBox:(CGRect)clearAperture
      orientation:(UIDeviceOrientation)orientation
{
    //[self PlayClick];
	NSArray *sublayers = [NSArray arrayWithArray:[self.previewLayer sublayers]];
	NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
	NSInteger featuresCount = [features count], currentFeature = 0;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for ( CALayer *layer in sublayers ) {
		if ( [[layer name] isEqualToString:@"FaceLayer"] )
			[layer setHidden:YES];
	}
	
	if ( featuresCount == 0 ) {
		[CATransaction commit];
		return; // early bail.
	}
    
	CGSize parentFrameSize = [self.previewView frame].size;
	NSString *gravity = [self.previewLayer videoGravity];
    BOOL videoMirrored;
    if ([self.previewLayer respondsToSelector:@selector(connection)])
    {
        videoMirrored = self.previewLayer.connection.isVideoMirrored;
    }
    else
    {
        NSLog(@"FAILURE");
    }
    
	BOOL isMirrored = videoMirrored;
	CGRect previewBox = [FindDistanceVC videoPreviewBoxForGravity:gravity
                                                        frameSize:parentFrameSize
                                                     apertureSize:clearAperture.size];
    // 60 milliseconds is .06 seconds
	for ( CIFaceFeature *ff in features ) {
        
		// find the correct position for the square layer within the previewLayer
		// the feature box originates in the bottom left of the video frame.
		// (Bottom right if mirroring is turned on)
        CGRect faceRect = [ff bounds];
        
		// flip preview width and height
		CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
		// scale coordinates so they fit in the preview box, which may be scaled
        //NSLog(@"height: %i",);
		CGFloat widthScaleBy = previewBox.size.width / clearAperture.size.height;
		CGFloat heightScaleBy = previewBox.size.height / clearAperture.size.width;
		faceRect.size.width *= widthScaleBy;
		faceRect.size.height = 50;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;
        
        //NSLog(@"X Distance:%f",fabsf(rightEyeX-leftEyeX));
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults valueForKey:@"currentFrame"]!=NULL)
        {
            NSNumber * currentFrameValue = [defaults valueForKey:@"currentFrame"];
            //NSLog(@"%i",[currentFrameValue intValue]);
            float actualDistance = pow((pow(abs(rightEyeX - leftEyeX),2)+pow(abs(rightEyeY - leftEyeY),2)),.5);
            //NSLog(@"actual distance:%f",actualDistance);
            if([currentFrameValue intValue]<frameDelay)
            {
                //NSLog(@"less than frame rate");
                NSNumber * incrementNumber = [NSNumber numberWithInteger:[[defaults valueForKey:@"currentFrame"] intValue]+1];
                [defaults setObject:incrementNumber forKey:@"currentFrame"];
                [defaults synchronize];
                NSNumber * addedValue = [NSNumber numberWithInteger:[[defaults valueForKey:@"addedSum"] intValue]+actualDistance];
                [defaults setObject:addedValue forKey:@"addedSum"];
                [defaults synchronize];
                
            }
            else
            {
                //NSLog(@"changing frame delay");
                NSString *soundFilePath =[[NSBundle mainBundle] pathForResource: @"EditedBeep" ofType: @"mp3"];
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
                AVAudioPlayer *newPlayer =
                [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                       error: NULL];
                self.player = newPlayer;
                [self.player prepareToPlay];
                [self.player setDelegate: self];
                [self.player play];
                if(actualDistance!=0)
                {
                    if (actualDistance>=19&&actualDistance<=26) {
                        counter++;
                    } else {
                        counter = 0;
                    }
                    
                    NSLog(@"Actual distance: %f",actualDistance);
                    if(actualDistance>=52)
                    {
                        frameDelay = 20;
                    }
                    else if(actualDistance<=51&&actualDistance>=45)
                    {
                        frameDelay = 17;
                    }
                    else if(actualDistance<=44&&actualDistance>=39)
                    {
                        frameDelay = 14;
                    }
                    else if(actualDistance<=38&&actualDistance>=33)
                    {
                        frameDelay = 11;
                    }
                    else if(actualDistance<=37&&actualDistance>=27)
                    {
                        frameDelay = 8;
                    }
                    else if (actualDistance>=19&&actualDistance<=26)
                    {
                        if (!executed) {
                            [self performSelector:@selector(stopMovingSound) withObject:self afterDelay:0];
                            executed = YES;
                        }
                        if (counter > 3) {
                            [self performSelector:@selector(transition) withObject:self afterDelay:2];
                        };
                        frameDelay = 5;
                    }
                    else if(actualDistance>=13&&actualDistance<=18)
                    {
                        frameDelay = 8;
                    }
                    else if(actualDistance<=12)
                    {
                        frameDelay = 11;
                    }
                }
                [defaults setObject:0 forKey:@"currentFrame"];
                
                //float averageValue = (float)([[defaults valueForKey:@"addedSum"] intValue])/(float)(10);
                //NSLog(@"added sum:%f", averageValue);
            }
        }
        else
        {
            NSNumber * zeroObject = [NSNumber numberWithInteger:0];
            [defaults setObject:zeroObject forKey:@"currentFrame"];
            [defaults setObject:zeroObject forKey:@"addedSum"];
        }
        
		if ( isMirrored )
			faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y+faceRect.size.height*(3/5));
		else
			faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y+faceRect.size.height*(3/5));
		
		CALayer *featureLayer = nil;
		// re-use an existing layer if possible
		while ( !featureLayer && (currentSublayer < sublayersCount) ) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
		
		// create a new one if necessary
		if ( !featureLayer ) {
			featureLayer = [[CALayer alloc]init];
            //NSLog(@"width:%f,height:%f",self.borderImage.size.width,self.borderImage.size.height);
			featureLayer.contents = (id)self.borderImage.CGImage;
			[featureLayer setName:@"FaceLayer"];
			[self.previewLayer addSublayer:featureLayer];
			featureLayer = nil;
		}
		[featureLayer setFrame:CGRectMake(faceRect.origin.x, faceRect.origin.y, 140  , faceRect.size.height)];
		
		switch (orientation) {
			case UIDeviceOrientationPortrait:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
				break;
			case UIDeviceOrientationLandscapeLeft:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
				break;
			case UIDeviceOrientationLandscapeRight:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
				break;
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
			default:
				break; // leave the layer in its last known orientation
		}
		currentFeature++;
	}
	
	[CATransaction commit];
}

-(void)PlayClick
{
    //NSLog(@"is beeping");
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                               pathForResource:@"EditedBeep"
                                               ofType:@"mp3"]];
    AVAudioPlayer *click = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
    [click play];
}


- (NSNumber *) exifOrientation: (UIDeviceOrientation) orientation
{
	int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (orientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (self.isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (self.isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    //exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
    return [NSNumber numberWithInt:exifOrientation];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    
	// get the image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
	if (attachments) {
		CFRelease(attachments);
    }
    
    // make sure your device orientation is not locked.
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
	NSDictionary *imageOptions = nil;
    
	imageOptions = [NSDictionary dictionaryWithObject:[self exifOrientation:curDeviceOrientation]
                                               forKey:CIDetectorImageOrientation];
    
	NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:imageOptions];
    for (CIFaceFeature *f in features)
    {
        if (f.hasLeftEyePosition)
        {
            leftEyeX = f.leftEyePosition.x;
            leftEyeY = f.leftEyePosition.y;
        }
        
        if (f.hasRightEyePosition)
        {
            rightEyeX = f.rightEyePosition.x;
            rightEyeY = f.rightEyePosition.y;
        }
        //NSLog(@"%f,%f",leftEyeX,rightEyeX);
    }
    
    if(leftEyeX!=-100000&&leftEyeY!=-100000&&rightEyeX!=-100000&&rightEyeY!=-100000)
    {
        CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self drawFaces:features
                forVideoBox:cleanAperture
                orientation:curDeviceOrientation];
        });
    }
}


#pragma mark - View lifecycle

- (void)viewWillLayoutSubviews
{
    if (![self.eyeExam.tests containsObject:@"Acuity"]) [self performSegueWithIdentifier:@"acuity" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self moveBackSound];
    
    //[self PlayClick];
    frameCounter = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:0 forKey:@"currentFrame"];
    [defaults setObject:0 forKey:@"addedSum"];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
	[self setupAVCapture];
	self.borderImage = [UIImage imageNamed:@"glasses.png"];
	NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self teardownAVCapture];
	self.faceDetector = nil;
	self.borderImage = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // We support only Portrait.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)transition
{
    [self teardownAVCapture];
	self.faceDetector = nil;
	self.borderImage = nil;
    [self performSegueWithIdentifier:@"acuity" sender:self];
}

- (void)moveBackSound
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/walkBackwards.mp3", [[NSBundle mainBundle] resourcePath]];;
    NSURL *pathURL = [NSURL fileURLWithPath : soundFilePath];
    
    SystemSoundID moveBackSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &moveBackSound);
    AudioServicesPlaySystemSound(moveBackSound);
}

- (void)stopMovingSound
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/stopMoving.mp3", [[NSBundle mainBundle] resourcePath]];;
    NSURL *pathURL = [NSURL fileURLWithPath : soundFilePath];
    
    SystemSoundID stopMovingSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &stopMovingSound);
    AudioServicesPlaySystemSound(stopMovingSound);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [[segue destinationViewController] setEyeExam:self.eyeExam];
}

@end
