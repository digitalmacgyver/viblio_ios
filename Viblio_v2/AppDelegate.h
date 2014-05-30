//
//  AppDelegate.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/6/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Additions.h"
#import "LoginNavigationController.h"

#define APPDEL ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@property(assign) BOOL isMoviePlayer;
@property (copy) void (^backgroundSessionCompletionHandler)();

-(void)presentNotification;
@end
