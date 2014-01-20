//
//  Session.m
//  Viblio_v2
//
//  Created by Vinay on 1/19/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "Session.h"


@implementation Session

@dynamic autoSyncEnabled;
@dynamic backgroundSyncEnabled;

- (NSString *)description
{
    return [NSString stringWithFormat:@"autoSyncEnabled: %@, backgroundSyncEnabled: %@", self.autoSyncEnabled, self.backgroundSyncEnabled];
}

@end
