//
//  VideoManager.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "VideoManager.h"
#import "NSString+Additions.h"

#define BUFFER_LEN 1024*1024*1

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
        
        if( self.asset.defaultRepresentation.size > 0 )
        {
            self.totalChunksSent++;
            DLog(@"Log : Total chunks sent - %d", self.totalChunksSent);
            
            static const NSUInteger BufferSize = BUFFER_LEN; // 256Kb chunk
            ALAssetRepresentation *rep = [self.asset defaultRepresentation];
            uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
            NSUInteger bytesRead = 0;
            NSError *error = nil;
            
            @try
            {
                bytesRead = [rep getBytes:buffer fromOffset:offsetOfUpload length:BufferSize error:&error];
                chunkData = [NSData dataWithData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            }
            @catch (NSException *exception)
            {
                free(buffer);
                chunkData = nil;
                // Handle the exception here...
            }
            
            free(buffer);
        }
        else
        {
            DLog(@"Log : The entries in asset and uploading are - %@,,,,,,,,,,,,,,%@", VCLIENT.asset, VCLIENT.videoUploading);
            DLog(@"Log : File has been deleted...");
            self.fileIdToBeDeleted = VCLIENT.videoUploading.fileLocation;
            DLog(@"Log : Cleaning up the entries in the DB for those not found in the camera roll....");
            [DBCLIENT deleteEntriesInDBForWhichNoAssociatedCameraRollRecordsAreFound:^(NSString *msg)
             {
                 
             }failure:^(NSError *error)
             {
                 DLog(@"Log : Deleting record did fail with error - %@", error);
             }];
            
            if( VCLIENT.asset != nil )
            {
                DLog(@"Log : Second list - The entries in asset and uploading are - %@,,,,,,,,,,,,,,%@", VCLIENT.asset, VCLIENT.videoUploading);
                DLog(@"Log : Deleting the files from App DB that have been deleted..... %@", VCLIENT.videoUploading.fileLocation);
                [APPCLIENT deleteTheFileWithID:self.fileIdToBeDeleted success:^(BOOL hasFileBeenDeleted)
                 {
                    // [self startNewFileUpload];
                 }failure:^(NSError *error)
                 {
                    // [self deleteFile];
                 }];
            }
            [APPCLIENT invalidateUploadTaskWithoutPausing];
        }
        
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
    if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
    {
        [APPCLIENT getOffsetOfTheFileAtLocationID:self.videoUploading.fileLocation sessionCookie:nil success:^(NSNumber *offsetObtained)
         {
             [self onSuccessOfGetOffSet:offsetObtained];
         }failure:^(NSError *error)
         {
             [self onFailureOfGetOffset:error];
         }];
    }
    else
    {
        [APPCLIENT getOffsetOfTheFileInBackgroundAtLocationID:self.videoUploading.fileLocation sessionCookie:nil success:^(NSNumber *offsetObtained)
         {
             [self onSuccessOfGetOffSet:offsetObtained];
         }failure:^(NSError *error)
         {
             [self onFailureOfGetOffset:error];
         }];
    }
}

-(void)onSuccessOfGetOffSet : (NSNumber*)offsetObtained
{
    DLog(@"Log : The offset obtained is - %@", offsetObtained);
    offset = offsetObtained.intValue;
    self.totalChunksSent = (offset)/(1024*1024*1);
    DLog(@"Log : total chunks sent count is - %d", self.totalChunksSent);
    APPCLIENT.uploadedSize = offset;
    [self videoFromNSData];
}

-(void)onFailureOfGetOffset : (NSError *)error
{
    DLog(@"LOG : %@ ---- errror code is , %ld", error, (long)error.code);
    if( error.code == -1003 || error.code == -1009 )
    {
        DLog(@"Log : Problem with server of internet connectivity.... Retry after some gap... Delay is set to be 5 seconds");
        [self performSelector:@selector(getOffsetFromTheHeadService) withObject:nil afterDelay:5];
        [self getOffsetFromTheHeadService];
    }
    else
    {
        DLog(@"Log : File not found on the server to continue... Delete and start afresh...");
        [self startNewFileUpload];
    }
}


-(void)deleteFile
{
    DLog(@"Log : Fetching offset Head failed for the file... We need to delete it from there and move on...");
    
    if( VCLIENT.asset != nil )
    {
        [APPCLIENT deleteTheFileWithID:VCLIENT.videoUploading.fileLocation success:^(BOOL hasFileBeenDeleted)
         {
             [self startNewFileUpload];
         }failure:^(NSError *error)
         {
             [self deleteFile];
         }];
    }
}


-(void)startNewFileUpload
{
    DLog(@"Log : The asset is - %@", self.asset);
    
    if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
    {
        [APPCLIENT startUploadingFileForUserId:APPMANAGER.user.userID fileLocalPath:self.asset.defaultRepresentation.url.absoluteString fileSize:[NSString stringWithFormat:@"%lld",self.asset.defaultRepresentation.size] success:^(NSString *fileLocation)
         {
             [self onSuccessOfNewUploadWithFileLoc:fileLocation];
         }failure:^(NSError *error)
         {
             [self onFailureOfNewUpload:error];
         }];
    }
    else
    {
        DLog(@"Log : App is in background... Use normal synhronous mutable request...");
        
        [APPCLIENT startUploadingFileInBackgroundForUserId:APPMANAGER.user.userID fileLocalPath:self.asset.defaultRepresentation.url.absoluteString fileSize:[NSString stringWithFormat:@"%lld",self.asset.defaultRepresentation.size] success:^(NSString *fileLocation)
        {
            [self onSuccessOfNewUploadWithFileLoc:fileLocation];
        }failure:^(NSError *error)
        {
            [self onFailureOfNewUpload:error];
        }];
    }
}

-(void)onSuccessOfNewUploadWithFileLoc : (NSString *)fileLocation
{
    DLog(@"Log : The file locaion Id is obtained --- %@", fileLocation);
    self.videoUploading.fileLocation = fileLocation;
    self.videoUploading.sync_status = @(1);
    
    [DBCLIENT updateFileLocationFile:self.asset.defaultRepresentation.url toLocation:self.videoUploading.fileLocation];
    [DBCLIENT updateSynStatusOfFile:self.videoUploading.fileURL syncStatus:1];
    
    // Set offset to 0 before starting uploading a new file. Offset has to be set to the value obtained from HEAD request if it is a resumable upload
    offset = 0;
    self.totalChunksSent = 0;
    [self videoFromNSData];
}

-(void)onFailureOfNewUpload : (NSError *)error
{
    DLog(@"LOG : The error is - %@",error);
    self.asset = nil; self.videoUploading = nil; APPCLIENT.uploadedSize = 0;
    [self videoUploadIntelligence];
    [[NSNotificationCenter defaultCenter]postNotificationName:uploadComplete object:nil];
}


-(void)videoFromNSData
{
    // offset that keep tracks of chunk data
    
    //    do {
    
    @autoreleasepool {
        NSData *chunkData = [self getDataPartAtOffset:offset];;
        
        
        if (chunkData == nil || chunkData.length <= 0 ) { // finished reading data
            
            if( self.asset != nil )
            {
                DLog(@"LOG : Chunk data failure --- %d --- %@",chunkData.length,chunkData);
                
                if( offset >= self.asset.defaultRepresentation.size )
                {
                    DLog(@"LOG : File transmission done");
                    DLog(@"Log : Remove the file record from DB ----");
                   // [DBCLIENT deleteOperationOnDB:self.videoUploading.fileURL];
                    [DBCLIENT updateIsCompletedStatusOfFile:self.asset.defaultRepresentation.url forCompletedState:YES];
                    
                    // Clean the video uploaded size
                    APPCLIENT.uploadedSize = 0;
                    
                    self.asset = nil;
                    self.videoUploading = nil;
                    
                    DLog(@"Log : Trying to fetch more files for uploading");
                    
                    [self videoUploadIntelligence];
                    
                    if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
                        [[NSNotificationCenter defaultCenter]postNotificationName:uploadComplete object:nil];
                   
                }
                else
                {
                    DLog(@"Log : File transmission has not completed but chunk data length is 0 !!.. Initiating failure fallback..");
                    [self uploadFailureFallBack : nil];
                }
            }
            else
            {
                DLog(@"Log : Asset is nil... No asset found for chunking...");
                [self videoUploadIntelligence];
            }
        }
        else
        {
            DLog(@"-------------------------------- OFFSET CHUNK SIZE INFO ------------------------------------------------------");
            DLog(@" LOG : Offset is - %f ", offset);
            DLog(@"LOG : Chunk Size is - %d", chunkData.length);
            
            DLog(@"------------------------------------**************************----------------------------------------------- ");
            
            // In no case file which has completed its transmission should get stuck
            
            if( offset + chunkData.length > self.asset.defaultRepresentation.size  )
            {
                DLog(@"Log : Something went wrong in the offset.... Better to take the head of the file and start sending PATCH requests...");
                [self getOffsetFromTheHeadService];
            }
            else
            {
                // do your stuff here
                
                // Ensure that offset doesnt jump in multiples of chunkdata length
                
//                if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground )
//                {
//                    DLog(@"Log : App is in background and the chunks transferred in backgrounds are - %d", self.backgroundStartChunk);
//                    if( self.backgroundStartChunk > 4 && !self.backgroundAlertShown )
//                    {
//                        self.backgroundAlertShown = YES;
//                        [((AppDelegate*)([UIApplication sharedApplication].delegate)) presentNotification];
//                    }
//                    self.backgroundStartChunk++;
//                }
                
                DLog(@"LOG : ------------- OFFSET and ChunkData cross reference ------------");
                DLog(@"Log : Offset is --- %f, chunkdata uploaded is ----- %d", offset, (self.totalChunksSent-1)*BUFFER_LEN);
                if( offset > (self.totalChunksSent-1) * BUFFER_LEN )
                {
                    DLog(@"Log : Offset jumping off randomnly.. Something sheepy.. Better to go with the HEAD of the file and proceed.");
                    [self getOffsetFromTheHeadService];
                }
                else
                {
                    [APPCLIENT resumeUploadOfFileLocationID:self.videoUploading.fileLocation localFileName:@"movieTrial" chunkSize:[NSString stringWithFormat:@"%d",chunkData.length]  offset:[NSString stringWithFormat:@"%f",offset] chunk:chunkData sessionCookie:nil success:^(NSString *msg)
                     {
                         DLog(@"LOG : Uploading next chunk---- completed upload till offset - %f",offset);
                         DLog(@"LOG : 1 / %f th part uploading..... ", offset/self.asset.defaultRepresentation.size);
                         
//                         if( VCLIENT.isToBePaused )
//                         {
//                             [DBCLIENT updateIsPausedStatusOfFile:VCLIENT.asset.defaultRepresentation.url forPausedState:1];
//                             [self uploadFailureFallBack:nil];
//                             VCLIENT.isToBePaused = NO;
//                         }
//                         else
//                         {
                             offset += chunkData.length;
                             APPCLIENT.uploadedSize = offset;
                             [self videoFromNSData];
//                         }
                         
                     }failure:^(NSError *error)
                     {
                         DLog(@"Log : The error code is - %d", error.code);
                         DLog(@"Log : Error uploading file and the error is - %@", error);
                         [self uploadFailureFallBack : error];
                     }];
                }
            }
        }
    }
}


-(void)uploadFailureFallBack : (NSError *)error
{
    // Commiting to DB that the File has failed
    
    // If server not reachable
    if( error.code == -1004 )
    {
        APPMANAGER.errorCode = 1003;
        [APPCLIENT invalidateUploadTaskWithoutPausing];
    }
    else
    {
        [DBCLIENT updateFailStatusOfFile:self.asset.defaultRepresentation.url toStatus:@(1)];
        
        // Commit the uploaded bytes to the DB
        [DBCLIENT updateUploadedBytesForFile:self.asset.defaultRepresentation.url toBytes:@( ((self.totalChunksSent-1)*1024*1024) + APPCLIENT.uploadedSize)];
        
        self.asset = nil; self.videoUploading = nil; APPCLIENT.uploadedSize = 0;
        
        if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
            [self videoUploadIntelligence];
        else
            DLog(@"Log : App is in background.. Dont initiate next request...");
        
        
        DLog(@"Log : Status after saving - %@", [DBCLIENT listAllEntitiesinTheDB]);
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:uploadComplete object:nil];
}



/************************************************ Video Upload intelligence ************************************************************************/

-(void)videoUploadIntelligence
{
    if( APPMANAGER.signalStatus != 0 )
    {
        if( APPMANAGER.activeSession.wifiupload.integerValue && APPMANAGER.signalStatus == 2 )
        {
            DLog(@"Log : Connected over Wifi... Upload only on Wifi enabled too...");
            [self fetchVideosForUploadingAndStartUpload];
        }
        else
        {
            DLog(@"Log : ");
            if( ( APPMANAGER.activeSession.wifiupload.integerValue == 0 ) )
            {
                DLog(@"Log : Connected via cellular data and wifi only upload is disabled too.... ");
                APPMANAGER.turnOffUploads = NO;
                [self fetchVideosForUploadingAndStartUpload];
            }
            else
            {
                if( VCLIENT.asset != nil )
                {
                    if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive )
                    {
                        [ViblioHelper displayAlertWithTitle:@"Not on WiFi" messageBody:@"Uploading paused until WiFi connection established" viewController:nil cancelBtnTitle:@"OK"];
                    }
                    [APPCLIENT invalidateUploadTaskWithoutPausing];
                    APPMANAGER.turnOffUploads = YES;
                }

                DLog(@"Log : Settings for upload and uploader connectivity status does not match....");
            }
        }
    }
}

-(void)fetchVideosForUploadingAndStartUpload
{
    [DBCLIENT updateDB:^(NSString *msg)
     {
         DLog(@"Log : The DB has been successfully updated");
         
         VCLIENT.isBkgrndTaskEnded = YES;
         //    if (VCLIENT.bgTask != UIBackgroundTaskInvalid)
         //    {
         //        [[UIApplication sharedApplication] endBackgroundTask:VCLIENT.bgTask];
         //        VCLIENT.bgTask = UIBackgroundTaskInvalid;
         //    }
         if( self.asset == nil && !APPMANAGER.turnOffUploads)
         {
             NSMutableArray *videoList = [[DBCLIENT fetchVideoListToBeUploaded] mutableCopy];
             DLog(@"Log : The list of videos to be uploaded are - %@", videoList);
             if( videoList != nil && videoList.count > 0 )
             {
                 DLog(@"Log : The autoSyncStatus is - %@", APPMANAGER.activeSession.autoSyncEnabled);
                 
                 self.videoUploading = (Videos*)[videoList firstObject];
                 self.asset = [self getAssetFromFilteredVideosForUrl: self.videoUploading.fileURL];
                 
                 if([self.videoUploading.sync_status  isEqual: @(0)] || ![self.videoUploading.fileLocation isValid])
                 {
                     DLog(@"Log : New file.. File location will not be existing...");
                     [self startNewFileUpload];
                     //VCLIENT.isBkgrndTaskEnded = YES;
                 }
                 else
                 {
                     DLog(@"Log : File already syncing and has been stopped at certain offset....");
                     DLog(@"Log : The video and asset details are as follows - %@ --------- %@", self.videoUploading, self.asset);
                     [self getOffsetFromTheHeadService];
                     //VCLIENT.isBkgrndTaskEnded = YES;
                 }
             }
             else
             {
                 DLog(@"Log : All videos are synced.. No videos to be uploaded");
                 self.asset = nil;
                 self.videoUploading = nil;
                 
                 // Enable auto lock as there are no uploads in progress
                 [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
             }
         }
         else
             DLog(@"Log : An upload in progress..... or uploads are turned off");
         
     }failure:^(NSError *error)
     {
         DLog(@"Log : Error in updating DB");
         
     }];
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
