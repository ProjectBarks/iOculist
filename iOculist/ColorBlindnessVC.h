//
//  ColorBlindnessVC.h
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EyeExam.h"

@interface ColorBlindnessVC : UIViewController

- (void)finishedListening:(NSString *)hypothesis;

@property (strong, nonatomic) EyeExam *eyeExam;

@end
