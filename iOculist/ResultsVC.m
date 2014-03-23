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
    self.visualAcuityLabel.text = self.eyeExam.acuityScore;
    self.colorBlindnessLabel.text = self.eyeExam.colorBlindnessScore;
    self.astigmatismLabel.text = self.eyeExam.astigmatismScore;
    
    if ([self.eyeExam.acuityScore isEqualToString:@"20/200"] || [self.eyeExam.acuityScore isEqualToString:@"20/100"] || [self.eyeExam.acuityScore isEqualToString:@"20/70"]) {
        self.visualAcuityLabel.textColor = [UIColor redColor];
    }
    
    if ([self.eyeExam.colorBlindnessScore isEqualToString:@"YES"]) {
        self.colorBlindnessLabel.textColor = [UIColor redColor];
    }
    
    if ([self.eyeExam.astigmatismScore isEqualToString:@"YES"]) {
        self.astigmatismLabel.textColor = [UIColor redColor];
    }
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
