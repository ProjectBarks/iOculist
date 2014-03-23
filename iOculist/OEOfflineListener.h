//
//  OEOfflineListener.h
//  openEars
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LanguageModelGenerator;
@class PocketsphinxController;
@class OpenEarsEventsObserver;

@interface OEOfflineListener : NSObject

- (id)initWithWords:(NSArray *)words VC:(UIViewController *)VC;

@property (strong, nonatomic) LanguageModelGenerator *lmGenerator;
@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

@property (strong, nonatomic) NSString *hypothesis;
@property (nonatomic) BOOL finished;
@property (strong, nonatomic) NSString *correctAnswer;

@end