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
}

@end
