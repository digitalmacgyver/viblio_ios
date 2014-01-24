//
//  UserManager.h
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserClient [UserManager sharedClient]

@interface UserManager : NSObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * emailId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * isFbUser;
@property (nonatomic, retain) NSString * fbAccessToken;
@property (nonatomic, retain) NSString * sessionCookie;
@property (nonatomic, retain) NSNumber * isNewUser;

+ (UserManager *)sharedClient;

@end
