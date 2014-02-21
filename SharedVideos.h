//
//  SharedVideos.h
//  Viblio_v2
//
//  Created by Vinay Raj on 13/02/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedVideos : NSObject

@property(nonatomic, strong) NSString *mediaUUID;
@property(nonatomic, strong) NSString *ownerUUID;
@property(nonatomic, assign) NSString *viewCount;
@property(nonatomic, strong) NSString *createdDate;
@property(nonatomic, strong) NSString *ownerName;
@property(nonatomic, strong) NSString *posterURL;
@property(nonatomic, strong) NSString *sharedDate;

@end
