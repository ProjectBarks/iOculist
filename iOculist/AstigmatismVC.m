//
//  AstigmatismVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "AstigmatismVC.h"
#import "OEOfflineListener.h"

@interface AstigmatismVC ()
@property (strong, nonatomic) OEOfflineListener *listener;
@end

@implementation AstigmatismVC

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
    self.listener = [[OEOfflineListener alloc] initWithWords:@[@"YES", @"NO"] VC:self];
    [self performSelectorInBackground:@selector(waitForListener) withObject:self];
}

- (void)waitForListener
{
    while (!self.listener.finished) {}
    
    if ([self.listener.hypothesis isEqualToString:@"YES"]) {
        self.eyeExam.astigmatismScore = @"Yes";
    } else {
        self.eyeExam.astigmatismScore = @"No";
    }
    
    [self performSelectorOnMainThread:@selector(transition) withObject:self waitUntilDone:NO];
}

- (void)transition
{
    NSLog(@"Transitioning");
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        for (UIView *view in self.view.subviews) {
            view.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        NSLog(@"Done.");
        [self performSegueWithIdentifier:@"results" sender:self];
    }];
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
