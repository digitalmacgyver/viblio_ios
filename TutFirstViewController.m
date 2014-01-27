//
//  TutFirstViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/16/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "TutFirstViewController.h"

@interface TutFirstViewController ()

@end

@implementation TutFirstViewController

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
     [self.navigationController.navigationBar setBackgroundImage:[ViblioHelper setUpNavigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];

    self.lblContent.numberOfLines = 0;
    self.lblHeading.font = [ViblioHelper viblio_Font_Regular_WithSize:30 isBold:NO];
    self.lblContent.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    
    APPDEL.navController = self.navigationController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSecondTutorial:(id)sender {
    DLog(@"LOG : Right swipe detected");
}

- (IBAction)skipTutorial:(id)sender {
    LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void)
     {
         [lvc performSegueWithIdentifier: @"dashboardNav" sender:self];
     }];
}
@end
