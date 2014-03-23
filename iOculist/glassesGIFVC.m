//
//  glassesGIFVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/23/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "glassesGIFVC.h"

@interface glassesGIFVC ()
@property (weak, nonatomic) IBOutlet UIImageView *glassesGIF;

@end

@implementation glassesGIFVC

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
    // NSURL *url = [[NSBundle mainBundle] URLForResource:@"glassesInst" withExtension:@"gif"];
    // self.glassesGIF.image = [UIImage animatedImageWithAnimatedGIFURL:url];
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
