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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSecondTutorial:(id)sender {
    DLog(@"LOG : Right swipe detected");
}

@end
