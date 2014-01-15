//
//  SignInViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/9/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

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


- (IBAction)LoginClick:(id)sender {
}

- (IBAction)FBAccountClick:(id)sender {
}

- (IBAction)EmailAccountClick:(id)sender {
}

- (IBAction)EmailLogin:(id)sender {
    
//    DLog(@"User Login through email authentication");
//    [APPCLIENT authenticateUserWithEmail:self.email.text password:self.password.text type:@"db" success:^(User *user)
//    {
//        DLog(@"LOG : User session created successfully ---");
//        DLog(@"LOg : The user details obtained are as follows - %@",user);
//        
//    }failure:^(NSError *error)
//    {
//        
//    }];
}

- (IBAction)FBLogin:(id)sender {
    
//    [FBSession.activeSession closeAndClearTokenInformation];
//    [FBSession setActiveSession:nil];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    
    [APPAUTH authorizeToGetInfoAboutMeWithCompleteBlock:^(NSError *err) {
        
        NSLog(@"LOG : Block entered after validation");
    } inView:self.view];
}


@end
