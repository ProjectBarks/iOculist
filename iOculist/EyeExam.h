//
//  EyeExam.h
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface EyeExam : NSObject

@property (strong, nonatomic) NSString *acuityScore;
@property (strong, nonatomic) NSString *colorBlindnessScore;
@property (strong, nonatomic) NSString *astigmatismScore;

@property (strong, nonatomic) NSArray *tests;

@end
