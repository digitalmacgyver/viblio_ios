//
//  cloudVideos.m
//  Viblio_v2
//
//  Created by Vinay Raj on 11/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "cloudVideos.h"

@implementation cloudVideos

@synthesize uuid;
@synthesize url;
@synthesize createdDate;
@synthesize lat;
@synthesize longitude;
@synthesize shareCount;

- (NSString *)description
{
    return [NSString stringWithFormat:@"uuid: %@, url: %@, createdDate : %@, latitude : %@, longitude : %@, isShared : %d, faces : %@", self.uuid, self.url, self.createdDate, self.lat, self.longitude, self.shareCount, self.faces];
}

@end
