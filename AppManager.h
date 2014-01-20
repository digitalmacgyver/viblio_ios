//
//  AppManager.h
//  Viblio_v2
//
//  Created by Vinay on 1/18/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Session.h"

#define APPMANAGER [AppManager sharedClient]

@interface AppManager : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Session *activeSession;

+ (AppManager *)sharedClient;

@end
