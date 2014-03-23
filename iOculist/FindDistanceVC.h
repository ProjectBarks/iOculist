//
//  FindDistanceVC.h
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EyeExam.h"

@interface FindDistanceVC : UIViewController
<UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,AVAudioPlayerDelegate>
{
    NSNumber * frameCounter;
    NSNumber * frameSum;
}

@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, strong) EyeExam *eyeExam;

-(void) transition;

@end
