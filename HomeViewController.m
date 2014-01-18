//
//  HomeViewController.m
//  Viblio_v2
//
//  Created by Vinay on 1/17/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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
  //  self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"menu")];
	// Do any additional setup after loading the view.
}

- (IBAction)touchMeClicked:(id)sender {
    
    DLog(@"LOG : Touch Me detected");
    
    [APPCLIENT getCountOfMediaFilesUploadedByUser:^(int count)
    {
        DLog(@"Log : The count obtained is - %d", count);
    }failure:^(NSError *error)
    {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenuList:(id)sender {
    
    DLog(@"Log : Reveal sliding menu");
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
