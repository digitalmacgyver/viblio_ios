//
//  AppManager.m
//  Viblio_v2
//
//  Created by Vinay on 1/18/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+ (AppManager *)sharedClient {
    static AppManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

@end
