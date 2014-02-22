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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)LoginClick:(id)sender {
    DLog(@"Log : Detecting login click");
    [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"LogInNav") sender:self];
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
            
            [APPCLIENT createNewUserAccountWithFB:fbAccessToken type:@"facebook" success:^(NSString *msg)
            {
                // Stop activity indicator
                [self.activity stopAnimating];
                
                // Persist the user details in the DB until the user logs out
                [DBCLIENT persistUserDetailsWithEmail:UserClient.emailId password:nil userID:UserClient.userID isNewUser:UserClient.isNewUser isFbUser:UserClient.isFbUser sessionCookie:UserClient.sessionCookie fbAccessToken:UserClient.fbAccessToken];
                
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
        
        } inView:self.view];
}

- (IBAction)EmailAccountClick:(id)sender {
   [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"SignUpNav") sender:self];
}

@end
