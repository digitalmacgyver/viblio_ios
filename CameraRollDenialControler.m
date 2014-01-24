//
//  CameraRollDenialControlelrViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "CameraRollDenialControler.h"

@interface CameraRollDenialControler ()

@end

@implementation CameraRollDenialControler

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
    
    self.lblHeading.font = [ViblioHelper viblio_Font_Regular_WithSize:30 isBold:NO];
    self.lblContent1.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    self.lblContent2.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
    
    self.navigationController.navigationBarHidden = YES;
   // self.btnLogout.titleLabel.textColor = [UIColor orangeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)provideAccessClicked:(id)sender {
}

- (IBAction)logoutClicked:(id)sender {
    [ViblioHelper clearSessionVariables];
    DLog(@"Log : Logout clicked");
    DLog(@"Log : The root class is - %@", NSStringFromClass([self.parentViewController class]));
    if( [self.parentViewController isKindOfClass:[InitialSlidingViewController class]] )
    {
        LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void)
         {
             [lvc performSegueWithIdentifier: Viblio_wideNonWideSegue( @"signInNav" ) sender:self];
         }];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
