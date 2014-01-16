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
    [APPCLIENT getOffsetOfTheFileAtLocationID:@"f3c552f0-7e22-11e3-9ee5-2bc59fa2be56" sessionCookie:nil success:^(NSString *msg)
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
            [APPCLIENT resumeUploadOfFileLocationID:@"790d57b0-7e5e-11e3-9ee5-2bc59fa2be56" localFileName:@"movieTrialPav" chunkSize:[NSString stringWithFormat:@"%d",chunkData.length]  offset:[NSString stringWithFormat:@"%d",offset] chunk:chunkData sessionCookie:nil success:^(NSString *msg)
             {
                 NSLog(@"LOG : Uploading next chunk---- completed upload till offset - %d",offset);
                 
                 NSLog(@"LOG : 1 / %lld th part uploading..... ", offset/self.asset.defaultRepresentation.size);
                 
                 [self videoFromNSData];
                 
             }failure:^(NSError *error)
             {
                 offset -=[chunkData length];
                 [self videoFromNSData];
             }];
            
            offset +=[chunkData length];
        }
    }
}


@end
