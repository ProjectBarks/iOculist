//
//  WelcomeVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "WelcomeVC.h"
#import "OEOfflineListener.h"

@interface WelcomeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIButton *tapToStartButton;
@property (strong, nonatomic) OEOfflineListener *listener;
@end

@implementation WelcomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.listener = [[OEOfflineListener alloc] initWithWords:@[@"TEST"] VC:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setInitialPositions];
    [self performAnimations];
}

- (void)setInitialPositions
{
    self.logoImage.alpha = 0;
    self.tapToStartButton.transform = CGAffineTransformMakeTranslation(0, 600);
}

- (void)performAnimations
{
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.logoImage.alpha = 1;
        
    } completion:^(BOOL finished){
        
        [UIView animateWithDuration:1 animations:^{
            
            self.tapToStartButton.transform = CGAffineTransformMakeTranslation(0, 0);
            
        } completion:nil];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
