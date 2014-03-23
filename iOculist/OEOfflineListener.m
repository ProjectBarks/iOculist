//
//  OEOfflineListener.m
//  openEars
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "OEOfflineListener.h"
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface OEOfflineListener () <OpenEarsEventsObserverDelegate> {}
@property (strong, nonatomic) NSArray *words;
@property (strong, nonatomic) UIViewController *VC;
@property (nonatomic) int tries;
@end

@implementation OEOfflineListener
@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;

- (id)initWithWords:(NSArray *)words VC:(UIViewController *)VC;
{
    self = [super init];
    
    if (self) {
        self.lmGenerator = [[LanguageModelGenerator alloc] init];
        self.words = words;
        self.tries = 1;
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [self.lmGenerator generateLanguageModelFromArray:self.words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    NSDictionary *languageGeneratorResults = nil;
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    
    [self.openEarsEventsObserver setDelegate:self];
}

- (PocketsphinxController *)pocketsphinxController
{
    if (!pocketsphinxController) pocketsphinxController = [[PocketsphinxController alloc] init];
	return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (!openEarsEventsObserver) openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	return openEarsEventsObserver;
}

- (void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	// NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    NSLog(@"Hypothesis: %@", hypothesis);
    NSLog(@"Recognition Score: %@", recognitionScore);
    if ([recognitionScore integerValue] > -1000 || [hypothesis isEqualToString:self.correctAnswer] || self.tries > 1) {
        self.hypothesis = hypothesis;
        self.finished = YES;
        self.tries = 1;
    } else {
        self.tries += 1;
        [self performSelector:@selector(pleaseRepeat) withObject:self afterDelay:1];
    }
}

- (void) pocketsphinxDidStartCalibration {
	// NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	// NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
    [self performSelector:@selector(clickSound) withObject:self afterDelay:4];
}

- (void) pocketsphinxDidDetectSpeech {
	// NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	// NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	// NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	// NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	// NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	// NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	// NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	// NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (void)pleaseRepeat
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/pleaseRepeat.mp3", [[NSBundle mainBundle] resourcePath]];;
    NSURL *pathURL = [NSURL fileURLWithPath : soundFilePath];
    
    SystemSoundID pleaseRepeat;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &pleaseRepeat);
    AudioServicesPlaySystemSound(pleaseRepeat);
}

- (void)clickSound
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/clickSound.mp3", [[NSBundle mainBundle] resourcePath]];;
    NSURL *pathURL = [NSURL fileURLWithPath : soundFilePath];
    
    SystemSoundID clickSound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &clickSound);
    AudioServicesPlaySystemSound(clickSound);
}

@end
