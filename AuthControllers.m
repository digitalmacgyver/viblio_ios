//
//  AuthControllers.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/9/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "AuthControllers.h"

@interface AuthControllers ()

@end

@implementation AuthControllers

+ (AuthControllers *)sharedInstance {
    static AuthControllers *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)authorizeToGetInfoAboutMeWithCompleteBlock:(void(^)(NSError*))cblock inView:(UIView *)view
{
    NSLog(@"LOG : In here");
    
    NSArray *permissions = @[ @"email", @"user_birthday", @"user_photos", @"user_location", @"user_status", @"user_likes" ];
    
    
    if ([[FBSession activeSession] isOpen])
    {
        
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSLog(@"%@",user);//Displayed with the gender
                 NSLog(@"%@",user.name);//Name only displayed
                 NSLog(@"%@",[user objectForKey:@"gender"]);//Build error
                 
                 [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                     if (error == nil)
                     {
                         [APPCLIENT authenticateUserWithFacebook:FBSession.activeSession.accessTokenData.accessToken type:@"facebook" success:^(User *user)
                          {
                              
                          }failure:^(NSError *error)
                          {
                              
                          }];
                     }
                 }];
             }
         }];
    }
    else
    {
        [self fbSessionEsteblish:permissions :view :^(NSError* error)
         {
             cblock(error);
         }];
    }
    
}

-(void)fbSessionEsteblish:(NSArray*)permissions :(UIView*)view :(void(^)(NSError* error))success
{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      switch (status) {
                                          case FBSessionStateOpen:
                                              [self authorizeToGetInfoAboutMeWithCompleteBlock:success inView:view];
                                              break;
                                          case FBSessionStateCreatedOpening:
                                              [[FBSession activeSession] handleDidBecomeActive];
                                              break;
                                          case FBSessionStateClosed:
                                              if (success)
                                                  success(error);
                                              break;
                                          case FBSessionStateClosedLoginFailed:
                                          {
                                              [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Facebook Session could not be established" viewController:nil cancelBtnTitle:@"OK"];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"FBSessionError" object:nil];
                                          }
                                              break;
                                          default:
                                              break;
                                      }
                                  }];
}

@end
