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
    });
    return _sharedClient;
}

- (NSData *)getDataPartAtOffset:(NSInteger)offsetOfUpload  {
    __block NSData *chunkData = nil;
    if (self.asset){
        static const NSUInteger BufferSize = BUFFER_LEN; // 1 MB chunk
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
        NSUInteger bytesRead = 0;
        NSError *error = nil;
        
        @try
        {
            bytesRead = [rep getBytes:buffer fromOffset:offsetOfUpload length:BufferSize error:&error];
            NSLog(@"LOG : Bytes read length - %d",bytesRead);
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
        NSLog(@"failed to retrive Asset");
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

// Function to find differece between two dates

- (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return (int)([components day]);
    
//    [self fetchVideosFromCameraRoll:[df dateFromString: str] success:^(NSArray *filteredVideos)
//     {
//         for ( ALAsset *asset in filteredVideos )
//         {
//             NSManagedObjectContext *context = [DBCLIENT managedObjectContext];
//             Videos *video = [NSEntityDescription
//                              insertNewObjectForEntityForName:@"Videos"
//                              inManagedObjectContext:context];
//             
//             video.fileURL = [asset.defaultRepresentation.url absoluteString];
//             video.sync_status = [NSNumber numberWithInt:0];
//
//             NSError *error;
//             if (![context save:&error]) {
//                 NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//             }
//         }
//     }failure:^(NSError *error)
//     {
//         switch ([error code]) {
//             case ALAssetsLibraryAccessUserDeniedError:
//             case ALAssetsLibraryAccessGloballyDeniedError:
//                 [ViblioHelper displayAlertWithTitle:@"Access Denied" messageBody:@"Please enable access to Camera Roll" viewController:nil cancelBtnTitle:@"OK"];
//                 //[ViblioHelper displayAlert:@"Access Denied" :@"Please enable access to Camera Roll" :nil :@"OK"];
//                 break;
//             default:
//                 NSLog(@"Reason unknown.");
//                 break;
//         }
//     }];
//    df = nil; str = nil;
}

-(void)otherServices
{
    NSLog(@"LOG : The asset details are - %@",self.asset);
    
    [APPCLIENT authenticateUserWithEmail:@"vinay@cognitiveclouds.com" password:@"MaraliMannige4" type:@"db" success:^(User *user)
     {
         NSLog(@"LOG : Modal user object obtained is - %@",user);
         
     }failure:^(NSError *error)
     {
         
     }];
}

-(void)getOffsetFromTheHeadService
{
    [APPCLIENT getOffsetOfTheFileAtLocationID:self.videoUploading.fileLocation sessionCookie:nil success:^(double offsetObtained)
     {
         DLog(@"Log : The offset obtained is - %lf", offsetObtained);
         offset = offsetObtained;
         [self videoFromNSData];
     }failure:^(NSError *error)
     {
         NSLog(@"LOG : %@", error);
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
         NSLog(@"LOG : The error is - %@",error);
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
            
            NSLog(@"LOG : Chunk data failure --- %d --- %@",chunkData.length,chunkData);
            NSLog(@"LOG : File transmission done");
            
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
        }
        else
        {
            // do your stuff here
            [APPCLIENT resumeUploadOfFileLocationID:self.videoUploading.fileLocation localFileName:@"movieTrialSunday" chunkSize:[NSString stringWithFormat:@"%d",chunkData.length]  offset:[NSString stringWithFormat:@"%f",offset] chunk:chunkData sessionCookie:nil success:^(NSString *msg)
             {
                 NSLog(@"LOG : Uploading next chunk---- completed upload till offset - %f",offset);
                 
                 NSLog(@"LOG : 1 / %f th part uploading..... ", offset/self.asset.defaultRepresentation.size);
                 
                 [self videoFromNSData];
                 
             }failure:^(NSError *error)
             {
//                 offset -=[chunkData length];
//                 [self videoFromNSData];
                 DLog(@"Log : Error uploading file and the error is - %@", error);
                 // Commiting to DB that the File has failed
                 [DBCLIENT updateFailStatusOfFile:self.asset.defaultRepresentation.url toStatus:@(1)];
                 self.asset = nil; self.videoUploading = nil;
                 
                 if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
                     [self videoUploadIntelligence];
                 else
                     DLog(@"Log : App is in background.. Dont initiate next request...");
             }];
            
            offset +=[chunkData length];
        }
    }
}


/************************************************ Video Upload intelligence ************************************************************************/

-(void)videoUploadIntelligence
{
//    if( self.asset == nil )
//    {
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
//    }
//    else
//        DLog(@"Log : An upload in progress.....");
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
