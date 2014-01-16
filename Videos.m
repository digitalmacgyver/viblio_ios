//
//  Videos.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "Videos.h"


@implementation Videos

@dynamic fileURL;
@dynamic sync_status;
@dynamic sync_time;
@dynamic hasFailed;

- (NSString *)description
{
    return [NSString stringWithFormat:@"fileURL: %@, sync_status: %@, sync_time : %@,hasFailed :  %@", self.fileURL, self.sync_status, self.sync_time, self.hasFailed];
}

@end
