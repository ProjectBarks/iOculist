//
//  VisualAcuityVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "VisualAcuityVC.h"
#import "OEOfflineListener.h"
#import "ColorBlindnessVC.h"

@interface VisualAcuityVC ()
@property (weak, nonatomic) IBOutlet UILabel *snellsonText;
@property (strong, nonatomic) OEOfflineListener *listener;
@property (strong, nonatomic) NSArray *acceptableCharacters;
@property (strong, nonatomic) NSString *correctAnswer;
@property (nonatomic) int visionEstimate;
@end

@implementation VisualAcuityVC

- (NSString *)generateText:(int)length
{
    NSString *text = @"";
    for (int i = 0; i < length; i++) {
        int index = arc4random_uniform((int)self.acceptableCharacters.count);
        text = [text stringByAppendingString:[NSString stringWithFormat:@"%@ ", self.acceptableCharacters[index]]];
    }
    
    if ([text length] > 0) {
        text = [text substringToIndex:[text length] - 1];
    } else {
        //no characters to delete... attempting to do so will result in a crash
    }
    
    self.correctAnswer = text;
    self.listener.correctAnswer = text;
    return text;
}

- (void)finishedListening:(NSString *)hypothesis
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listener = [[OEOfflineListener alloc] initWithWords:self.acceptableCharacters VC:self];
    [self startTest];
}

- (void)startTest
{
    NSLog(@"Starting Test");
    NSString *text = [self generateText:round(200.0/self.visionEstimate)];
    self.snellsonText.text = text;
    self.snellsonText.font = [UIFont systemFontOfSize:(self.visionEstimate/11)*8.5371];
    [self performSelectorInBackground:@selector(waitForListener) withObject:self];
    NSLog(@"Finishing Starting Test");
}

- (void)waitForListener
{
    NSLog(@"Waiting for Listener");
    while (!self.listener.finished) {}
    self.listener.finished = NO;
    
    if (![self.listener.hypothesis isEqualToString:self.correctAnswer]) {
        NSLog(@"Inorrect");
        self.eyeExam.acuityScore = [NSString stringWithFormat:@"20/%d", self.visionEstimate];
        [self performSelectorOnMainThread:@selector(transition) withObject:self waitUntilDone:NO];
    } else {
        NSLog(@"Correct");
        if (self.visionEstimate > 20) {
            if (self.visionEstimate == 200) {
                self.visionEstimate = 100;
            } else if (self.visionEstimate == 100) {
                self.visionEstimate = 70;
            } else if (self.visionEstimate == 70) {
                self.visionEstimate = 50;
            } else if (self.visionEstimate == 50) {
                self.visionEstimate = 40;
            } else if (self.visionEstimate == 40) {
                self.visionEstimate = 30;
            } else {
                self.visionEstimate = 20;
            }
            
            [self startTest];
        } else {
            NSLog(@"20/20 Vision");
            self.eyeExam.acuityScore = @"20/20";
            [self performSelectorOnMainThread:@selector(transition) withObject:self waitUntilDone:NO];
        }
    }
}

- (void)transition
{
    NSLog(@"Transitioning");
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        for (UIView *view in self.view.subviews) {
            view.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"colorBlindness" sender:self];
    }];
}

- (void)listen
{
    NSLog(@"Voice Input: %@", self.listener.hypothesis);
}

- (NSArray *)acceptableCharacters
{
    if (!_acceptableCharacters) _acceptableCharacters =  @[@"E", @"F", @"O", @"L", @"A", @"H", @"I", @"M", @"Q", @"R", @"S"];
    return _acceptableCharacters;
}

- (int)visionEstimate
{
    if (!_visionEstimate) _visionEstimate = 200;
    return _visionEstimate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
