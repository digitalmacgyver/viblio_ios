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

-(NSDictionary*)getSessionKeysAndValues
{
    return @{ @"autoSyncEnabled" : self.activeSession.autoSyncEnabled,
              @"backgroundSyncEnabled" : self.activeSession.backgroundSyncEnabled,
              @"wifiupload" : self.activeSession.wifiupload,
              @"autolockdisable" : self.activeSession.autolockdisable,
              @"batterSaving" : self.activeSession.batterSaving };
}

-(NSArray*)getSectionsList
{
    return @[@"Today", @"This Week", @"This Month", @"This Year", @"Older"];
}

-(NSArray*)getSettings
{
    return  @[
                                     @{@"title" : @"Wifi Upload", @"detail" : @"Upload only over wifi connection"},
                                     @{@"title" : @"Background Uploading", @"detail" : @"Upload videos when app is in background"},
                                     @{@"title" : @"Power Saving", @"detail" : @"Stops uploading files when battery gets less than 20%"},
                                     @{@"title" : @"Avoid Auto Lock", @"detail" : @"Don't auto lock the screen when the app is processing videos"}];
}

@end
