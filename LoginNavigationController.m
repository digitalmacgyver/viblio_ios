//
//  LoginNavigationController.m
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "LoginNavigationController.h"

@interface LoginNavigationController ()

@end

@implementation LoginNavigationController

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
    
    APPDEL.navController = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
