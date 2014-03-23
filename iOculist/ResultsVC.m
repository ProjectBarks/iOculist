//
//  ResultsVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "ResultsVC.h"

@interface ResultsVC ()
@property (weak, nonatomic) IBOutlet UILabel *visualAcuityLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorBlindnessLabel;
@property (weak, nonatomic) IBOutlet UILabel *astigmatismLabel;

@end

@implementation ResultsVC

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
    self.visualAcuityLabel.text = [NSString stringWithFormat:@"Visual Acuity: %@", self.eyeExam.acuityScore];
    self.colorBlindnessLabel.text = [NSString stringWithFormat:@"Color Blindness: %@", self.eyeExam.colorBlindnessScore];
    self.astigmatismLabel.text = [NSString stringWithFormat:@"Astigmatism: %@", self.eyeExam.astigmatismScore];
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
