//
//  SharedVideos.m
//  Viblio_v2
//
//  Created by Vinay Raj on 13/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "SharedVideos.h"

@implementation SharedVideos

@synthesize mediaUUID;
@synthesize ownerUUID;
@synthesize viewCount;
@synthesize createdDate;
@synthesize ownerName;
@synthesize posterURL;

- (NSString *)description
{
    return [NSString stringWithFormat:@"mediaUUID : %@, ownerUUID : %@, viewCount : %@, createdDate : %@, ownerName : %@, posterURL : %@", self.mediaUUID, self.ownerUUID, self.viewCount, self.createdDate, self.ownerName, self.posterURL];
}

@end
