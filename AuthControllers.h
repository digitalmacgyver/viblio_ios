//
//  AuthControllers.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/9/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthControllers : NSObject

+ (AuthControllers *)sharedInstance;
- (void)authorizeToGetInfoAboutMeWithCompleteBlock:(void(^)(NSError*, NSString *))cblock inView:(UIView *)view;

@end
