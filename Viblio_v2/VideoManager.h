//
//  VideoManager.h
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

#define VCLIENT [VideoManager sharedClient]

@interface VideoManager : NSObject
{
    __block int i, videosCount;
    int offset;
}
@property(nonatomic,retain)NSMutableArray *filteredVideoList;

@property(nonatomic, retain)NSMutableArray *chunks;

@property(nonatomic,strong)ALAsset *asset;

+ (VideoManager *)sharedClient;
-(void)loadAssetsFromCameraRoll:(void (^)(NSArray *filteredVideoList))success
                        failure:(void (^)(NSError *error))failure;


-(void)otherServices;
-(void)startNewFileUpload;
-(int)getOffsetFromTheHeadService;
-(void)videoFromNSData;

@end
