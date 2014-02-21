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
    

    
    [self performSelector:@selector(navigateToSignIn) withObject:nil afterDelay:1];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
//    __block NSArray *userResults; //= [DBCLIENT getUserDataFromDB];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        userResults = [DBCLIENT getUserDataFromDB];
//    });
//    
//    
//    if( userResults != nil && userResults.count > 0 )
//    {
//        APPMANAGER.user = [userResults firstObject];
//        [self performSegueWithIdentifier:(@"dashboardNav") sender:self];
//        
//        DLog(@"Log : Calling Video Manager to check if an upload was interrupted...");
//        if([APPMANAGER.user.userID isValid])
//            [VCLIENT videoUploadIntelligence];
//    }
//    else
//    {
//        DLog(@"Log : User session does not exist..");
//        [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"signInNav") sender:self];
//    }
}

-(void)navigateToSignIn
{
    NSArray *userResults = [DBCLIENT getUserDataFromDB];
    if( userResults != nil && userResults.count > 0 )
    {
             APPMANAGER.user = [userResults firstObject];
             [self performSegueWithIdentifier:(@"dashboardNav") sender:self];
        
             DLog(@"Log : Calling Video Manager to check if an upload was interrupted...");
             if([APPMANAGER.user.userID isValid])
                 [VCLIENT videoUploadIntelligence];
    }
    else
    {
        DLog(@"Log : User session does not exist..");
       [self performSegueWithIdentifier:Viblio_wideNonWideSegue(@"signInNav") sender:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
