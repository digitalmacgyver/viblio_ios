//
//  Session.m
//  Viblio_v2
//
//  Created by Vinay on 1/23/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "Session.h"


@implementation Session

@dynamic autoSyncEnabled;
@dynamic backgroundSyncEnabled;
@dynamic wifiupload;
@dynamic autolockdisable;
@dynamic batterSaving;

- (NSString *)description
{
    return [NSString stringWithFormat:@"autoSyncEnabled: %@, backgroundSyncEnabled: %@, wifiupload : %@, autolockdisable : %@, batterSaving : %@", self.autoSyncEnabled, self.backgroundSyncEnabled, self.wifiupload, self.autolockdisable, self.batterSaving];
}


@end
