//
//  VideoManager.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "VideoManager.h"
#import "NSString+Additions.h"

#define BUFFER_LEN 1024*256*1

@interface VideoManager ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation VideoManager

+ (VideoManager *)sharedClient {
    static VideoManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
        _sharedClient.pageCount = 1;
    });
    return _sharedClient;
}

- (NSData *)getDataPartAtOffset:(NSInteger)offsetOfUpload  {
    __block NSData *chunkData = nil;
    if (self.asset){
        static const NSUInteger BufferSize = BUFFER_LEN; // 256Kb chunk
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
        NSUInteger bytesRead = 0;
        NSError *error = nil;
        
        @try
        {
            bytesRead = [rep getBytes:buffer fromOffset:offsetOfUpload length:BufferSize error:&error];
            DLog(@"LOG : Bytes read length - %d",bytesRead);
            chunkData = [NSData dataWithData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
        }
        @catch (NSException *exception)
        {
            free(buffer);
            chunkData = nil;
            // Handle the exception here...
        }
        
        free(buffer);
    } else {
        DLog(@"failed to retrive Asset");
    }
    return chunkData;
}


-(void)loadAssetsFromCameraRoll:(void (^)(NSArray *assetList))success
                        failure:(void (^)(NSError *error))failure
{

    NSMutableArray *filteredUniqueVideos = [NSMutableArray array];
    
    // Log Access Denial Errors
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) { failure(error); };
    
    // Block for enumerating individual videos from groups
    ALAssetsGroupEnumerationResultsBlock enumerationBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if( asset != nil )
            [filteredUniqueVideos addObject:asset];
        else
            success( filteredUniqueVideos );
    };
    
    // emumerate through our groups and only add groups that contain videos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        [group enumerateAssetsUsingBlock:enumerationBlock];
    };
    
    // Alloc if existing library is nil
    if (self.assetsLibrary == nil)
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:listGroupBlock failureBlock:failureBlock];
}

-(void)getOffsetFromTheHeadService
{
    [APPCLIENT getOffsetOfTheFileAtLocationID:self.videoUploading.fileLocation sessionCookie:nil success:^(double offsetObtained)
     {
         DLog(@"Log : The offset obtained is - %lf", offsetObtained);
         offset = offsetObtained;
         APPCLIENT.uploadedSize = offset;
         [self videoFromNSData];
     }failure:^(NSError *error)
     {
         DLog(@"LOG : %@", error);
         [self deleteFile];
     }];
}


-(void)deleteFile
{
    DLog(@"Log : Fetching offset HEAd failed for the file... We need to delete it from there and move on...");
    
    [APPCLIENT deleteTheFileWithID:VCLIENT.videoUploading.fileLocation success:^(BOOL hasFileBeenDeleted)
     {
        [self startNewFileUpload];
     }failure:^(NSError *error)
     {
         [self deleteFile];
     }];
}


-(void)startNewFileUpload
{
    DLog(@"Log : The asset is - %@", self.asset);
    [APPCLIENT startUploadingFileForUserId:APPMANAGER.user.userID fileLocalPath:self.asset.defaultRepresentation.url.absoluteString fileSize:[NSString stringWithFormat:@"%lld",self.asset.defaultRepresentation.size] success:^(NSString *fileLocation)
     {
         DLog(@"Log : The file locaion Id is obtained --- %@", fileLocation);
         self.videoUploading.fileLocation = fileLocation;
         self.videoUploading.sync_status = @(1);
         
         DLog(@"Log : Updating DB for file location");
         [DBCLIENT updateFileLocationFile:self.asset.defaultRepresentation.url toLocation:self.videoUploading.fileLocation];
         
         DLog(@"Log : Updating the DB for sync_status of the video file");
         [DBCLIENT updateSynStatusOfFile:self.videoUploading.fileURL syncStatus:1];
         
         // Set offset to 0 before starting uploading a new file. Offset has to be set to the value obtained from HEAD request if it is a resumable upload
         offset = 0;
         [self videoFromNSData];
     }failure:^(NSError *error)
     {
         DLog(@"LOG : The error is - %@",error);
         self.asset = nil; self.videoUploading = nil; APPCLIENT.uploadedSize = 0;
         
         if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
             [self videoUploadIntelligence];
         else
             DLog(@"Log : App is in background.. Dont initiate next request...");
         
         [[NSNotificationCenter defaultCenter]postNotificationName:uploadComplete object:nil];
     }];
    
}

-(void)videoFromNSData
{
    // offset that keep tracks of chunk data
    
    //    do {
    
    @autoreleasepool {
        NSData *chunkData = [self getDataPartAtOffset:offset];;
        
        
        if (!chunkData || ![chunkData length]) { // finished reading data
            // break;
            
            if( self.asset != nil )
            {
                DLog(@"LOG : Chunk data failure --- %d --- %@",chunkData.length,chunkData);
                DLog(@"LOG : File transmission done");
                
                DLog(@"Log : Remove the file record from DB ----");
                [DBCLIENT deleteOperationOnDB:self.videoUploading.fileURL];
                
                // Clean the video uploaded size
                APPCLIENT.uploadedSize = 0;
                
                self.asset = nil;
                self.videoUploading = nil;
                
                DLog(@"Log : Trying to fetch more files for uploading");
                
                if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
                    [self videoUploadIntelligence];
                else
                    DLog(@"Log : App is in background.. Dont initiate next request...");
                
                [[NSNotificationCenter defaultCenter]postNotificationName:uploadComplete object:nil];
            }
            

        }
        else
        {
            DLog(@"-------------------------------- OFFSET CHUNK SIZE INFO ------------------------------------------------------");
            DLog(@" LOG : Offset is - %f ", offset);
            DLog(@"LOG : Chunk Size is - %d", chunkData.length);
            
            DLog(@"------------------------------------**************************----------------------------------------------- ");
            
            // do your stuff here
            [APPCLIENT resumeUploadOfFileLocationID:self.videoUploading.fileLocation localFileName:@"movieTrial" chunkSize:[NSString stringWithFormat:@"%d",chunkData.length]  offset:[NSString stringWithFormat:@"%f",offset] chunk:chunkData sessionCookie:nil success:^(NSString *msg)
             {
                 DLog(@"LOG : Uploading next chunk---- completed upload till offset - %f",offset);
                 
                 DLog(@"LOG : 1 / %f th part uploading..... ", offset/self.asset.defaultRepresentation.size);
                 
                 APPCLIENT.uploadedSize = offset;
                 [self videoFromNSData];
                 
             }failure:^(NSError *error)
             {
//                 offset -=[chunkData length];
//                 [self videoFromNSData];
                 DLog(@"Log : Error uploading file and the error is - %@", error);
                 // Commiting to DB that the File has failed
                 [DBCLIENT updateFailStatusOfFile:self.asset.defaultRepresentation.url toStatus:@(1)];
                 
                 // Commit the uploaded bytes to the DB
                 [DBCLIENT updateUploadedBytesForFile:self.asset.defaultRepresentation.url toBytes:@(APPCLIENT.uploadedSize)];
                 
                 self.asset = nil; self.videoUploading = nil; APPCLIENT.uploadedSize = 0;
                 
                 if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
                     [self videoUploadIntelligence];
                 else
                     DLog(@"Log : App is in background.. Dont initiate next request...");
                 
                 [[NSNotificationCenter defaultCenter]postNotificationName:uploadComplete object:nil];
             }];
            
            offset +=[chunkData length];
        }
    }
}


/************************************************ Video Upload intelligence ************************************************************************/

-(void)videoUploadIntelligence
{
    if( self.asset == nil && !APPMANAGER.turnOffUploads)
    {
        NSMutableArray *videoList = [[DBCLIENT fetchVideoListToBeUploaded] mutableCopy];
        
        if( videoList != nil && videoList.count > 0 )
        {
            DLog(@"Log : The autoSyncStatus is - %@", APPMANAGER.activeSession.autoSyncEnabled);
            DLog(@"Log : The list of videos to be uploaded are - %@", videoList);
            self.videoUploading = (Videos*)[videoList firstObject];
            self.asset = [self getAssetFromFilteredVideosForUrl: self.videoUploading.fileURL];
            
            if([self.videoUploading.sync_status  isEqual: @(0)] || ![self.videoUploading.fileLocation isValid])
            {
                DLog(@"Log : New file.. File location will not be existing...");
                [self startNewFileUpload];
            }
            else
            {
                DLog(@"Log : File already syncing and has been stopped at certain offset....");
                DLog(@"Log : The video and asset details are as follows - %@ --------- %@", self.videoUploading, self.asset);
                [self getOffsetFromTheHeadService];
            }
        }
        else
        {
            DLog(@"Log : All videos are synced.. No videos to be uploaded");
            self.asset = nil;
            self.videoUploading = nil;
        }
    }
    else
        DLog(@"Log : An upload in progress..... or uploads are turned off");
}

/*------------------------------------------------------- Function to get the ALAsset by passing asset URL -----------------------------------------*/

-(ALAsset*)getAssetFromFilteredVideosForUrl:(NSString*)url
{
    for (ALAsset *asset in self.filteredVideoList)
    {
        if( [asset.defaultRepresentation.url.absoluteString isEqualToString:url] )
        {
            DLog(@"Log : Asset found.. And the asset is - %@", asset);
            return asset;
        }
    }
    return nil;
}


@end
