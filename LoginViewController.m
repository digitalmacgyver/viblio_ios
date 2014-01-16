//
//  LoginViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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

- (IBAction)BackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ForgotPasswordClick:(id)sender {
}


- (IBAction)LoginClick:(id)sender {
    
    DLog(@"LOG : Login clicked");
    
    // Authentication for user credentials
    
    if( [self.email isTextValid] && [self.password isTextValid] )
    {
        DLog(@"Authentication web service for email user being invoked --------------------------");
        
        [APPCLIENT authenticateUserWithEmail:self.email.text password:self.password.text type:@"db" success:^(User *user)
         {
             DLog(@"Success response with user details --- ");
             DLog(@"%@",user);
             
           //  [DBCLIENT updateDB];
             
             DLog(@"LOG : the class that has the control is - %@", NSStringFromClass([self.presentingViewController class]));
             LandingViewController *lvc = (LandingViewController*)self.navigationController.presentingViewController;
             
             [self.navigationController dismissViewControllerAnimated:YES completion:^(void)
             {
                 DLog(@"LOG : the class that has the control is - %@", NSStringFromClass([self.presentingViewController class]));
                 [lvc performSegueWithIdentifier:Viblio_wideNonWideSegue(@"tutorialNav") sender:self];
             }];
         }failure:^(NSError *error)
         {
             DLog(@"Error : Could not Login the user");
         }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma text field delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Shift the editable frame upwards
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = self.view.frame.origin.y - KeyBoardShiftSize;
    self.view.frame = viewFrame;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Shift the editable frame downwards
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = self.view.frame.origin.y + KeyBoardShiftSize;
    self.view.frame = viewFrame;
}

@end
