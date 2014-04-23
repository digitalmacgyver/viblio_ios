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

#pragma fb authentication functions

/*-------------------------------------------- FB Auth functions ---------------------------------------------------------------------------*/


- (void)authorizeToGetInfoAboutMeWithCompleteBlock:(void(^)(NSError*, NSString *fbAccessToken))cblock inView:(UIView *)view
{
    NSArray *permissions = @[ @"basic_info", @"email" ];
    
    if ([[FBSession activeSession] isOpen])
    {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 DLog(@"%@",user);//Displayed with the gender
                 DLog(@"%@",user.name);//Name only displayed
                 DLog(@"%@",[user objectForKey:@"gender"]);//Build error
                 DLog(@"%@", user[@"email"]);
                 
                 [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                     if (error == nil)
                     {
                         DLog(@"Log : Session successfully established... ");
                         cblock(error, FBSession.activeSession.accessTokenData.accessToken);
                     }
                 }];
             }
         }];
    }
    else
    {
        [self fbSessionEsteblish:permissions :view :^(NSError* error, NSString* fbAccessToken)
         {
             cblock(error, fbAccessToken);
         }];
    }
}

-(void)fbSessionEsteblish:(NSArray*)permissions :(UIView*)view :(void(^)(NSError*, NSString*))success
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
                                                  success(error, nil);
                                              break;
                                          case FBSessionStateClosedLoginFailed:
                                          {
                                              [ViblioHelper displayAlertWithTitle:@"Login" messageBody:@"Facebook Login failed. Could not establish session" viewController:nil cancelBtnTitle:@"OK"];
                                              success(nil, nil);
                                          }
                                              break;
                                          default:
                                              break;
                                      }
                                  }];
}

@end
