//
//  User.m
//  Viblio_v2
//
//  Created by Vinay on 1/22/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic userID;
@dynamic emailId;
@dynamic password;
@dynamic isFbUser;
@dynamic fbAccessToken;
@dynamic sessionCookie;
@dynamic isNewUser;
@dynamic userName;

-(NSString*)description
{
    return [NSString stringWithFormat:@"userId : %@, emailID : %@, password : %@, isFbUser : %@, fbAccessToken : %@, sessionCokkie : %@, isNewUser : %@, userName : %@", self.userID, self.emailId, self.password, self.isFbUser, self.fbAccessToken, self.sessionCookie, self.isNewUser, self.userName];
}

@end
