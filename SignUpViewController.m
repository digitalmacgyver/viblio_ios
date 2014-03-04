//
//  SignUpViewController.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

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
    
    // Customize text fields
    self.fName.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.fName.layer.borderWidth = 1.0f;
    self.fName.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:18 isBold:NO];
    
    self.lName.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.lName.layer.borderWidth = 1.0f;
        self.lName.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:18 isBold:NO];
    
    self.email.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.email.layer.borderWidth = 1.0f;
        self.email.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:18 isBold:NO];
    
    self.password.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.password.layer.borderWidth = 1.0f;
        self.password.font = [ViblioHelper viblio_Font_Light_Italic_WithSize:18 isBold:NO];
    
    self.lblPrivacy.font = [ViblioHelper viblio_Font_Light_WithSize:14 isBold:NO];
    self.lblTermsOfService.font = [ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO];
}

- (IBAction)SignUpClick:(id)sender {
    
    DLog(@"Log : Sign Up clicked");
    
    // Resign first rsponders for text fields
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.fName resignFirstResponder];
    [self.lName resignFirstResponder];
    
    if([self.email.text isValid] && [self.password.text isValid] && [self.fName.text isValid] && [self.lName.text isValid])
    {
        if([ViblioHelper vbl_isValidEmail:self.email.text])
        {
            // Start animating the spinner
            [self.sinUpActivity startAnimating];
            
            [APPCLIENT createNewUserAccountWithEmail:self.email.text password:self.password.text displayName:self.fName.text type:@"db" success:^(NSString *msg)
             {
                 [self.sinUpActivity stopAnimating];
                 DLog(@"Success response with user details --- ");

                 // Persist the user details in the DB until the user logs out
                 [DBCLIENT persistUserDetailsWithEmail:UserClient.emailId password:self.password.text userID:UserClient.userID isNewUser:UserClient.isNewUser isFbUser:UserClient.isFbUser sessionCookie:UserClient.sessionCookie fbAccessToken:UserClient.fbAccessToken userName:UserClient.userName];
                 
                 APPMANAGER.user = [[DBCLIENT getUserDataFromDB] firstObject];
                 
                 // Perform an DB update for storing the assetsas well
                 [DBCLIENT updateDB:^(NSString *msg)
                 {
                     DLog(@"Log : DB update successfull.. Proceed");
                     LandingViewController *lvc = (LandingViewController*)self.navigationController.presentingViewController;
                     [self.navigationController dismissViewControllerAnimated:YES completion:^(void)
                      {
                          if( APPMANAGER.user.isNewUser )
                          {
                              DLog(@"LOG : New user tutorials have to be shown");
                              [lvc performSegueWithIdentifier:Viblio_wideNonWideSegue(@"tutorialNav") sender:self];
                          }
                          else
                          {
                              DLog(@"LOG : Not new user... Take him to dashboard");
                              [lvc performSegueWithIdentifier: Viblio_wideNonWideSegue(@"dashboardNav") sender:self];
                          }
                      }];
                 }failure:^(NSError *error)
                 {
                     DLog(@"Log : Error is - %@", error);
                     [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"cameradenial")] animated:YES];
                 }];    
             }failure:^(NSError *error)
             {
                 [self.sinUpActivity stopAnimating];
                 DLog(@"Log : Error could not sign up the user");
                 [ViblioHelper displayAlertWithTitle:@"" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
             }];
        }
        else
            [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Please fill valid email id" viewController:self cancelBtnTitle:@"OK"];
    }
    else
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Please fill all fields" viewController:self cancelBtnTitle:@"OK"];
}

- (IBAction)BackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
