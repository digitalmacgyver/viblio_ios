//
//  LandingViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "LandingViewController.h"

@interface LandingViewController ()

@end

@implementation LandingViewController

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
   // self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"signinNavTop")];
//    [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"signInNav") sender:self];
    [self performSelector:@selector(navigateToSignIn) withObject:nil afterDelay:1];
	// Do any additional setup after loading the view.
}

-(void)navigateToSignIn
{
    //    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dashboard"];
    [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"signInNav") sender:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
