//
//  User.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/8/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *sessionCookie;

+ (NSDictionary *)mapping;

@end
