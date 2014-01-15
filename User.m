//
//  User.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/8/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)mapping
{
    return @{
             @"uuid": @"userID"
             };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@, session_cookie: %@, email : %@, isfbuser : %d", self.userID, self.sessionCookie, self.emailId, self.isFBUser];
}

@end
