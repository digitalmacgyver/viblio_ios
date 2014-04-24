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
    
    self.lblSignUpWith.font = [ViblioHelper viblio_Font_Italic_WithSize:14 isBold:NO];
    DLog(@"Log : Posting the device token to the server - ");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)LoginClick:(id)sender {
    DLog(@"Log : Detecting login click");
    
    DLog(@"LOG : Login clicked");
    
    [self.txtUserName resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    // Authentication for user credentials
    
    if( [self.txtUserName isTextValid] && [self.txtPassword isTextValid] )
    {
        // Check whether email id valid or not
        
        if( [ViblioHelper vbl_isValidEmail:self.txtUserName.text] )
        {
            // Start the activity indicator
            [self.activity startAnimating];
        
            DLog(@"Authentication web service for email user being invoked --------------------------");
            
            [APPCLIENT authenticateUserWithEmail:self.txtUserName.text password:self.txtPassword.text type:@"db" success:^(NSString *msg)
             {
                 // Stop activity indicator
                 [self.activity stopAnimating];
                 
                 // Persist the user details in the DB until the user logs out
                 [DBCLIENT persistUserDetailsWithEmail:UserClient.emailId password:self.txtPassword.text userID:UserClient.userID isNewUser:UserClient.isNewUser isFbUser:UserClient.isFbUser sessionCookie:UserClient.sessionCookie fbAccessToken:UserClient.fbAccessToken userName:UserClient.userName];
                 
                 APPMANAGER.turnOffUploads = NO;
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
                 [self.activity stopAnimating];
                 
                 DLog(@"Error : Could not Login the user");
                 
                 if(error.code == -1009)
                     [ViblioHelper displayAlertWithTitle:@"" messageBody:@"The Internet is my life force and you don’t seem to be connected. Get connected quick!" viewController:self cancelBtnTitle:@"OK"];
                 else
                     [ViblioHelper displayAlertWithTitle:@"" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
             }];
        }
        else
            [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"I don't recognize that email format. Wanna try agian ?" viewController:self cancelBtnTitle:@"OK"];
    }
    else
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"hmmm. Something's missing... email or password perhaps? Let's try it again." viewController:self cancelBtnTitle:@"OK"];
    
    //[self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"LogInNav") sender:self];
}


- (IBAction)forgotPasswordClicked:(id)sender {
    
    DLog(@"Log : Forgot Password Clicked");
    
    [self.txtUserName resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    if( [self.txtUserName isTextValid] )
    {
        if( [ViblioHelper vbl_isValidEmail:self.txtUserName.text] )
        {
            // Start spinner animation
            [self.activity startAnimating];
            
            [APPCLIENT passwordForgot:self.txtUserName.text success:^(NSString *message)
             {
                 [self.activity stopAnimating];
                 
                 [ViblioHelper displayAlertWithTitle:@"Success" messageBody:[NSString stringWithFormat:@"Look out for an email at %@ from me to know your new reset password", self.txtUserName.text] viewController:self cancelBtnTitle:@"OK"];
             }failure:^(NSError *error)
             {
                 [self.activity stopAnimating];
                 
                 [ViblioHelper displayAlertWithTitle:@"Error" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
             }];
        }
        else
            [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"I don't recognize that email format. Wanna try agian ?" viewController:self cancelBtnTitle:@"OK"];
    }
    else
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"hmmm. Something's missing... email perhaps? Let's try it again." viewController:self cancelBtnTitle:@"OK"];
}


- (IBAction)FBAccountClick:(id)sender {
    DLog(@"Signing in through FB");
    
    [self.activity startAnimating];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    
    [APPAUTH authorizeToGetInfoAboutMeWithCompleteBlock:^(NSError *err, NSString* fbAccessToken) {
        
        [self.activity stopAnimating];
        
        if( err == nil && [fbAccessToken isValid] )
        {
            DLog(@"Log : Proceed to login");
            
            [self.activity startAnimating];
            
            [APPCLIENT authenticateUserWithFacebook:fbAccessToken type:@"facebook" success:^(NSString *msg)
             {
                 DLog(@"Log : user details obtained is - %@", UserClient.userName);
                 // Stop activity indicator
                 [self.activity stopAnimating];
                 
                 // Persist the user details in the DB until the user logs out
                 [DBCLIENT persistUserDetailsWithEmail:UserClient.emailId password:nil userID:UserClient.userID isNewUser:UserClient.isNewUser isFbUser:UserClient.isFbUser sessionCookie:UserClient.sessionCookie fbAccessToken:UserClient.fbAccessToken userName:UserClient.userName];
                 
                 APPMANAGER.turnOffUploads = NO;
                 APPMANAGER.user = [[DBCLIENT getUserDataFromDB] firstObject];
                 DLog(@"Log : The user details are - %@", APPMANAGER.user);
                 // Perform an DB update for storing the assetsas well
                 
                 [DBCLIENT updateDB:^(NSString *msg)
                  {
                      DLog(@"Log : DB update successfull.. Proceed");
                      LandingViewController *lvc = (LandingViewController*)self.navigationController.presentingViewController;
                      [self.navigationController dismissViewControllerAnimated:NO completion:^(void)
                       {
                               DLog(@"LOG : Not new user... Take him to dashboard");
                               [lvc performSegueWithIdentifier:(@"dashboardNav") sender:self];
                       }];
                  }failure:^(NSError *error)
                  {
                      DLog(@"Log : Error is - %@", error);
                      [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"cameradenial")] animated:YES];
                  }];

                 
             }failure:^(NSError *error)
            {
                if( error.code == 401 )
                {
                    [APPCLIENT createNewUserAccountWithFB:fbAccessToken type:@"facebook" success:^(NSString *msg)
                     {
                         // Stop activity indicator
                         [self.activity stopAnimating];
                         
                         // Persist the user details in the DB until the user logs out
                         [DBCLIENT persistUserDetailsWithEmail:UserClient.emailId password:nil userID:UserClient.userID isNewUser:UserClient.isNewUser isFbUser:UserClient.isFbUser sessionCookie:UserClient.sessionCookie fbAccessToken:UserClient.fbAccessToken userName:UserClient.userName];
                         
                         APPMANAGER.turnOffUploads = NO;
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
                         [self.activity stopAnimating];
                         
                         [ViblioHelper displayAlertWithTitle:@"Error" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
                     }];

                }
                else
                    [ViblioHelper displayAlertWithTitle:@"Error" messageBody:error.localizedDescription viewController:self cancelBtnTitle:@"OK"];
            }];

        }
        
        } inView:self.view];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)EmailAccountClick:(id)sender {
   [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"SignUpNav") sender:self];
}


- (IBAction)userNameEditingBegan:(id)sender {
    DLog(@"Log : user name began editing");
}


- (IBAction)userNameEditingEnd:(id)sender {
    DLog(@"Log : user name end editing");
}


- (IBAction)passwordEditingBegan:(id)sender {
    DLog(@"Log : password began editing");
}

- (IBAction)passwordEditingEnd:(id)sender {
    DLog(@"Log : password end editing");
}
@end
