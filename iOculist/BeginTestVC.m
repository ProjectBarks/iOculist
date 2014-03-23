//
//  BeginTestVC.m
//  iOculist
//
//  Created by Sam Pringle on 3/22/14.
//  Copyright (c) 2014 Sam Pringle. All rights reserved.
//

#import "BeginTestVC.h"
#import "EyeExam.h"
#import "VisualAcuityVC.h"

@interface BeginTestVC ()
@property (weak, nonatomic) IBOutlet UIButton *acuityButton;
@property (weak, nonatomic) IBOutlet UIButton *colorBlindnessButton;
@property (weak, nonatomic) IBOutlet UIButton *astigmatismButton;
@property (strong, nonatomic) EyeExam *eyeExam;
@property (strong, nonatomic) UIColor *bgBlue;
@end

@implementation BeginTestVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.bgBlue = self.acuityButton.backgroundColor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eyeExam = [[EyeExam alloc] init];
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    if ([sender titleColorForState:UIControlStateNormal] != [UIColor blueColor]) {
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    } else {
        [sender setTitleColor:self.bgBlue forState:UIControlStateNormal];;
    }
}

- (IBAction)beginButtonPressed:(UIButton *)sender
{
    NSMutableArray *tests = [[NSMutableArray alloc] init];
    NSArray *buttons = @[self.acuityButton, self.colorBlindnessButton, self.astigmatismButton];
    
    for (UIButton *button in buttons) {
        if ([sender titleColorForState:UIControlStateNormal] == [UIColor blueColor]) [tests addObject:[button titleForState:UIControlStateNormal]];
    }
    
    self.eyeExam.tests = tests;
    if (self.eyeExam.tests > 0) {
        [self performSegueWithIdentifier:@"findDistance" sender:self];
    }
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
    if ([[segue destinationViewController] respondsToSelector:@selector(setEyeExam:)]) {
        [[segue destinationViewController] setEyeExam:self.eyeExam];
    }
}

@end
