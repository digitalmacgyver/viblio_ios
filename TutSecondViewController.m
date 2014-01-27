//
//  TutSecondViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/16/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "TutSecondViewController.h"

@interface TutSecondViewController ()

@end

@implementation TutSecondViewController

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
    self.navigationItem.hidesBackButton = YES;
	// Do any additional setup after loading the view.
    
    self.lblHeading.font = [ViblioHelper viblio_Font_Regular_WithSize:30 isBold:NO];
    self.lblContent.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)skipTutorial:(id)sender {
    LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void)
     {
         [lvc performSegueWithIdentifier: @"dashboardNav" sender:self];
     }];
}


- (IBAction)showFirstTutorial:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
