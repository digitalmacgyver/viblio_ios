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
#import "Videos.h"

#define VCLIENT [VideoManager sharedClient]

@interface VideoManager : NSObject
{
    __block int i, videosCount;
    double offset;
}
@property(nonatomic,retain)NSMutableArray *filteredVideoList, *cloudVideoList;

@property(nonatomic, retain)NSMutableArray *chunks;
@property(nonatomic,strong)ALAsset *asset;
@property(nonatomic, strong)Videos *videoUploading;
@property(nonatomic, assign)BOOL shouldProceedWithNextFile;
@property(nonatomic, assign)NSInteger totalRecordsCount, pageCount;
@property (nonatomic, retain)NSDictionary *resCategorized;

+ (VideoManager *)sharedClient;
-(void)loadAssetsFromCameraRoll:(void (^)(NSArray *filteredVideoList))success
                        failure:(void (^)(NSError *error))failure;

-(void)startNewFileUpload;
-(void)getOffsetFromTheHeadService;
-(void)videoFromNSData;

-(void)videoUploadIntelligence;
-(ALAsset*)getAssetFromFilteredVideosForUrl:(NSString*)url;

@end
