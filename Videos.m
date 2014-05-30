//
//  Videos.m
//  Viblio_v2
//
//  Created by Vinay on 1/21/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "Videos.h"


@implementation Videos

@dynamic fileLocation;
@dynamic fileURL;
@dynamic hasFailed;
@dynamic isPaused;
@dynamic sync_status;
@dynamic sync_time;
@dynamic uploadedBytes;
@dynamic fileUUID;
@dynamic isCompleted;

- (NSString *)description
{
    return [NSString stringWithFormat:@"fileLocation: %@, fileURL: %@, hasFailed : %@, isPaused : %@, sync_status : %@, sync_time : %@, uploadedBytes : %@, fileUUID : %@, isCompleted : %@", self.fileLocation, self.fileURL, self.hasFailed, self.isPaused, self.sync_status, self.sync_time, self.uploadedBytes, self.fileUUID, self.isCompleted];
}

@end
