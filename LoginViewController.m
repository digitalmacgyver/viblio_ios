//
//  LoginViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "LoginViewController.h"

// Category for padding in text fields

@implementation UITextField (custom)
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
                      bounds.size.width - 20, bounds.size.height - 16);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end

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
    
    DLog(@"Log : In view did load on login view controller");
    
    [self.email setFont: [UIFont fontWithName:@"Aleo-LightItalic" size:18]];
    
    self.email.text = @"vinay@cognitiveclouds.com";
    self.password.text = @"MaraliMannige4";

	// Do any additional setup after loading the view.
    
    self.email.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.email.layer.borderWidth = 1.0f;
    
    self.password.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.password.layer.borderWidth = 1.0f;
    
    [self.btnForgotYourPass.titleLabel setFont:[ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO]];
    [self.btnLogin.titleLabel setFont:[ViblioHelper viblio_Font_Regular_WithSize:18 isBold:NO]];
    
}

- (IBAction)BackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ForgotPasswordClick:(id)sender {
    
    DLog(@"Log : Forgot Password Clicked");
    
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    if( [self.email isTextValid] )
    {
        if( [ViblioHelper vbl_isValidEmail:self.email.text] )
        {
            // Start spinner animation
            [self.loginActivity startAnimating];
            
            [APPCLIENT passwordForgot:self.email.text success:^(NSString *message)
             {
                 [self.loginActivity stopAnimating];
                 
                 [ViblioHelper displayAlertWithTitle:@"Success" messageBody:@"Reset password will be sent to your mail" viewController:self cancelBtnTitle:@"OK"];
             }failure:^(NSError *error)
             {
                 [self.loginActivity stopAnimating];
                 
                 [ViblioHelper displayAlertWithTitle:@"Error" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
             }];
        }
        else
            [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Please enter valid Email Id " viewController:self cancelBtnTitle:@"OK"];
    }
    else
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Email Id cannot be blank" viewController:self cancelBtnTitle:@"OK"];
}


- (IBAction)LoginClick:(id)sender {
    
    DLog(@"LOG : Login clicked");
    
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
        // Authentication for user credentials
        
        if( [self.email isTextValid] && [self.password isTextValid] )
        {
            // Check whether email id valid or not
            
            if( [ViblioHelper vbl_isValidEmail:self.email.text] )
            {
                // Start the activity indicator
                [self.loginActivity startAnimating];
                
                DLog(@"Authentication web service for email user being invoked --------------------------");
                
                [APPCLIENT authenticateUserWithEmail:self.email.text password:self.password.text type:@"db" success:^(NSString *msg)
                 {
                     // Stop activity indicator
                     [self.loginActivity stopAnimating];
                     
                     // Persist the user details in the DB until the user logs out
                     [DBCLIENT persistUserDetailsWithEmail:UserClient.emailId password:self.password.text userID:UserClient.userID isNewUser:UserClient.isNewUser isFbUser:UserClient.isFbUser sessionCookie:UserClient.sessionCookie fbAccessToken:UserClient.fbAccessToken];
                     
                     APPMANAGER.user = [[DBCLIENT getUserDataFromDB] firstObject];
                     DLog(@"Log : The user details are - %@", APPMANAGER.user);
                     // Perform an DB update for storing the assetsas well
                     
                     [DBCLIENT updateDB:^(NSString *msg)
                      {
                          DLog(@"Log : DB update successfull.. Proceed");
                          LandingViewController *lvc = (LandingViewController*)self.navigationController.presentingViewController;
                          [self.navigationController dismissViewControllerAnimated:NO completion:^(void)
                           {
                               if( [APPMANAGER.user.isNewUser integerValue] )
                               {
                                   DLog(@"LOG : New user tutorials have to be shown");
                                   [lvc performSegueWithIdentifier:Viblio_wideNonWideSegue(@"tutorialNav") sender:self];
                               }
                               else
                               {
                                   DLog(@"LOG : Not new user... Take him to dashboard");
                                   [lvc performSegueWithIdentifier:(@"dashboardNav") sender:self];
                               }
                           }];
                      }failure:^(NSError *error)
                      {
                          DLog(@"Log : Error is - %@", error);
                          [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"cameradenial")] animated:YES];
                      }];
                     
                 }failure:^(NSError *error)
                 {
                     // Stop activity indicator
                     [self.loginActivity stopAnimating];
                     
                     DLog(@"Error : Could not Login the user");
                     [ViblioHelper displayAlertWithTitle:@"" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
                 }];
            }
            else
                [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Please enter valid email" viewController:self cancelBtnTitle:@"OK"];
        }
        else
            [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Email/Password is blank" viewController:self cancelBtnTitle:@"OK"];
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( (textField.text.length-1 == 0) && (textField.text.length != 1) )
        textField.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:18 isBold:NO];
    else
        textField.font = [ViblioHelper viblio_Font_Regular_WithSize:18 isBold:NO];
        
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Shift the editable frame upwards

    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = self.view.frame.origin.y - KeyBoardShiftSize;
    self.view.frame = viewFrame;
    
    if( [textField.text isValid] )
            textField.font = [ViblioHelper viblio_Font_Regular_WithSize:18 isBold:NO];
    else
            textField.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:18 isBold:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    // Shift the editable frame downwards
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = self.view.frame.origin.y + KeyBoardShiftSize;
    self.view.frame = viewFrame;
}

@end
