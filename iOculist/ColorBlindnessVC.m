//
//  ColorBlindnessVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "ColorBlindnessVC.h"
#import "OEOfflineListener.h"

@interface ColorBlindnessVC ()
@property (weak, nonatomic) IBOutlet UIImageView *cbImageView;
@property (strong, nonatomic) NSDictionary *cbImages;
@property (strong, nonatomic) OEOfflineListener *listener;
@property (strong, nonatomic) NSDictionary *imageDictionary;

@property (strong, nonatomic) NSMutableDictionary *images;
@property (strong, nonatomic) NSString *correctAnswer;
@property (nonatomic) int score;
@end

@implementation ColorBlindnessVC

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
    
    if (![self.eyeExam.tests containsObject:@"Color Blindness"]) [self performSegueWithIdentifier:@"astigmatism" sender:self];
    
    self.score = 0;
    self.images = [[NSMutableDictionary alloc] init];
    [self.images setValuesForKeysWithDictionary:[self getImages]];
    NSArray *values = [self.images allValues];
    self.listener = [[OEOfflineListener alloc] initWithWords:values VC:self];
    [self loadImages];
}

- (void)waitForListener
{
    while (!self.listener.finished) {}
    if ([self.listener.hypothesis isEqualToString:self.correctAnswer]) self.score += 1;
    if ([[self.images allKeys] count] == 0) {
        NSLog(@"Do Not Load Images");
        if (self.score < 2) {
            self.eyeExam.colorBlindnessScore = @"Yes";
        } else {
            self.eyeExam.colorBlindnessScore = @"No";
        }
        
        [self performSelectorOnMainThread:@selector(transition) withObject:self waitUntilDone:YES];
    } else {
        NSLog(@"Load images");
        self.listener.finished = NO;
        [self loadImages];
    }
}

- (void)transition
{
    NSLog(@"Transitioning");
    NSLog(@"Score: %d", self.score);
    NSLog(@"Colorblind: %@", self.eyeExam.colorBlindnessScore);
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        for (UIView *view in self.view.subviews) {
            view.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"astigmatism" sender:self];
    }];
}

- (void)loadImages
{
    NSArray *keys = [self.images allKeys];
    NSArray *values = [self.images allValues];
    
    self.cbImageView.image = [UIImage imageNamed:[keys firstObject]];
    self.correctAnswer = [values firstObject];
    if ([self.images objectForKey:[keys firstObject]]) {
        [self.images removeObjectForKey:[keys firstObject]];
    }
    
    [self performSelectorInBackground:@selector(waitForListener) withObject:self];
}

- (NSDictionary *)getImages
{
    NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    NSArray *keys = [self.imageDictionary allKeys];
    NSArray *values = [self.imageDictionary allValues];
    int i = 0;
    while (i < 3) {
        int index = arc4random_uniform((int)self.imageDictionary.count);
        if (![images objectForKey:keys[index]]) {
            [images setObject:values[index] forKey:keys[index]];
            i++;
        }
    }
    
    NSDictionary *result = images;
    return result;
}
                                
- (NSDictionary *)imageDictionary
{
    if (!_imageDictionary) {
        
        _imageDictionary = @{@"cb42.gif" : @"FOURTYTWO",
                             @"cb26.gif" : @"TWENTYSIX",
                             @"cb73.gif" : @"SEVENTYTHREE",
                             @"cb16.gif" : @"SIXTEEN",
                             @"cb7.gif" : @"SEVEN",
                             @"cb5.gif" : @"FIVE",
                             @"cb45.gif" : @"FOURTYFIVE",
                             @"cb6.gif" : @"SIX",
                             @"cb74.gif" : @"SEVENTYFOUR",
                             @"cb15.gif" : @"FIFTEEN",
                             @"cb3.gif" : @"THREE",
                             @"cb29.gif" : @"TWENTYNINE",
                             @"cb8.gif" : @"EIGHT",
                             @"cb12.gif" : @"TWELVE"};
        
    }
    
    return _imageDictionary;
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
