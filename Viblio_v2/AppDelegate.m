//
//  AppDelegate.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/6/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

//@synthesize managedObjectContext = __managedObjectContext;
//@synthesize managedObjectModel = __managedObjectModel;
//@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
	self.backgroundSessionCompletionHandler = completionHandler;
    //add notification
  //  [self presentNotification];
}

-(void)presentNotification{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    int chunk = (int)(VCLIENT.asset.defaultRepresentation.size / 1048576);
    int rem = VCLIENT.asset.defaultRepresentation.size % 1048576;
    if(rem > 0)
        chunk++;
    
    localNotification.alertBody = [NSString stringWithFormat:@"%d chunks of %d completed", (int)APPCLIENT.uploadedSize/1048576, chunk];
    localNotification.alertAction = @"Background Transfer Upload!";
    
    //On sound
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    //increase the badge number of application plus 1
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    
    Session *session = [DBCLIENT getSessionSettings];
    APPMANAGER.turnOffUploads = NO;
    
    if( session == nil )
    {
        [DBCLIENT insertDefaultSettingsIntoSession];
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    }
    else
    {
        if( session.autolockdisable.integerValue )
            [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        else
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    }
    session = nil;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSArray *userResults = [DBCLIENT getUserDataFromDB];
    if( userResults != nil && userResults.count > 0 )
    {
        DLog(@"Log : User session exits.. Peform update on DB here");
        [DBCLIENT updateDB:^(NSString *msg)
        {
            // Clean up all the entries in the DB for those not found in the camera roll
           // DLog(@"Log : Cleaning up the entries in the DB for those not found in the camera roll....");
           //  [DBCLIENT deleteEntriesInDBForWhichNoAssociatedCameraRollRecordsAreFound];
            
            DLog(@"Log : Calling Video Manager to check if an upload was interrupted...");
            if([APPMANAGER.user.userID isValid])
                [VCLIENT videoUploadIntelligence];
            
        }failure:^(NSError *error)
        {
            DLog(@"Log : Camera roll access denied case...");
        }];
    }
    else
    {
        DLog(@"Log : No user session exits.. User has to Login first...");
    }
    
    APPMANAGER.activeSession = (Session*)[DBCLIENT getSessionSettings];
    userResults = nil;
    [FBSession.activeSession handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DLog(@"Log : App is terminating");
    
    APPMANAGER.turnOffUploads = YES;
    [APPCLIENT invalidateFileUploadTask];
    APPCLIENT.uploadTask = nil;
    [FBSession.activeSession close];
}

@end
