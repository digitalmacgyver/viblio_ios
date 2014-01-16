//
//  TutThirdViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/16/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "TutThirdViewController.h"

@interface TutThirdViewController ()

@end

@implementation TutThirdViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)navigateToHomeScreen:(id)sender {
    
    DLog(@"LOG : Done clicked on tutorials");
    
    LandingViewController *lvc = (LandingViewController*)self.presentingViewController;
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^(void)
    {
        lvc.topViewController = [self.storyboard instantiateViewControllerWithIdentifier: @"dashboard"];
        
        //[lvc performSegueWithIdentifier: @"home" sender:self];
    }];
}

- (IBAction)showSecondTutorial:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
