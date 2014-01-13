//
//  VideoManager.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "VideoManager.h"

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

- (NSData *)getDataPartAtOffset:(NSInteger)offset  {
    __block NSData *chunkData = nil;
    if (self.asset){
        static const NSUInteger BufferSize = BUFFER_LEN; // 1 MB chunk
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
        NSUInteger bytesRead = 0;
        NSError *error = nil;
        
        @try
        {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:&error];
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


-(void)loadAssetsFromCameraRoll:(void (^)(NSArray *filteredVideoList))success
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

-(int)getOffsetFromTheHeadService
{
    [APPCLIENT getOffsetOfTheFileAtLocationID:@"12554130-776b-11e3-9ee5-2bc59fa2be56" sessionCookie:nil success:^(NSString *msg)
     {
         
     }failure:^(NSError *error)
     {
         NSLog(@"LOG : %@", error);
     }];
    return 1;
}

-(void)startNewFileUpload
{
    [APPCLIENT startUploadingFileForUserId:@"FD5C4166-67AC-11E3-B0E6-7B6FF9A9DC35" fileLocalPath:self.asset.defaultRepresentation.url.absoluteString fileSize:[NSString stringWithFormat:@"%lld",self.asset.defaultRepresentation.size] success:^(NSString *msg)
     {
         
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
                
            }
            else
            {
                // do your stuff here
                [APPCLIENT resumeUploadOfFileLocationID:@"12554130-776b-11e3-9ee5-2bc59fa2be56" localFileName:@"movieTrial" chunkSize:[NSString stringWithFormat:@"%d",chunkData.length]  offset:[NSString stringWithFormat:@"%d",offset] chunk:chunkData sessionCookie:nil success:^(NSString *msg)
                 {
//                     i++;
                     
//                     if ( i < self.chunks.count )
//                     {
                     NSLog(@"LOG : Uploading next chunk---- completed upload till offset - %d",offset);
                     
                         [self videoFromNSData];
//                     }
                     
                 }failure:^(NSError *error)
                 {
                     [self videoFromNSData];
                 }];
                
                    offset +=[chunkData length];
             }
            }
}

//-(void)fetchVideosFromCameraRoll
//                               success:(void (^)(NSArray *filteredVideoList))success
//                               failure:(void (^)(NSError *error))failure
//{
//    NSMutableArray *filteredUniqueVideos = [NSMutableArray array];
//    
//    // Log Access Denial Errors
//    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) { failure(error); };
//    
//    // Block for enumerating individual videos from groups
//    ALAssetsGroupEnumerationResultsBlock enumerationBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
//        if( asset != nil )
//        {
//            NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
//            NSComparisonResult result = [date compare:syncDate];
//            switch (result)
//            {
//                case NSOrderedDescending:
//                case NSOrderedAscending :
//                case NSOrderedSame: [filteredUniqueVideos addObject:asset]; break;
//                default: NSLog(@"erorr dates "); break;
//            }
//            date = nil;
//        }
//        else
//            success( filteredUniqueVideos );
//    };
//    
//    // emumerate through our groups and only add groups that contain videos
//    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
//        [group setAssetsFilter:[ALAssetsFilter allVideos]];
//        [group enumerateAssetsUsingBlock:enumerationBlock];
//    };
//    
//    // Alloc if existing library is nil
//    if (self.assetsLibrary == nil)
//        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
//    
//    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:listGroupBlock failureBlock:failureBlock];
//}


//-(NSArray*)fetchCategorizedVideoList:(NSArray*)filteredVideoList
//{
//    //    NSDate *currentDate = [NSDate date];
//    //    int datedifference = -1;
//    
//    //    VideosFilter *videoToday = [[VideosFilter alloc]init];
//    //    VideosFilter *videoYesterday = [[VideosFilter alloc]init];
//    //    VideosFilter *videoEarlier = [[VideosFilter alloc]init];
//    //    VideosFilter *videoToday = [[VideosFilter alloc]init];
//    //
//    //    for( ALAsset *asset in filteredVideoList )
//    //    {
//    //        datedifference = [self daysBetween:[asset valueForProperty:ALAssetPropertyDate] and:currentDate];
//    //        NSLog(@"LOG : The difference of days is - %d",datedifference);
//    //
//    //        switch (datedifference) {
//    //            case 0:
//    //                break;
//    //            case 1:
//    //                break;
//    //            default:
//    //                if( datedifference > 6 )
//    //                {
//    //
//    //                }
//    //                else
//    //                {
//    //
//    //                }
//    //                break;
//    //        }
//    //    }
//    return nil;
//}


// Function to find differece between two dates

- (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return (int)([components day]);
}


@end
