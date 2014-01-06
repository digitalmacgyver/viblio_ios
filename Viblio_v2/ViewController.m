//
//  ViewController.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ViewController.h"

#define BUFFER_LEN 1024*256

@interface ViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //  [self videoFromNSData];
    i = 0;
    self.chunks = [[NSMutableArray array]mutableCopy];
    
    [self loadAssetsFromCameraRoll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSData *)getDataPartAtOffset:(NSInteger)offset  {
    __block NSData *chunkData = nil;
    if (self.asset){
        static const NSUInteger BufferSize = BUFFER_LEN; // 5 MB chunk
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
        NSUInteger bytesRead = 0;
        NSError *error = nil;
        
        @try
        {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:&error];
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


-(void)loadAssetsFromCameraRoll
{
    NSString* str = @"2012-12-08 09:15:28 PM";
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    
    [self fetchUniqueVideosFromCameraRoll:[df dateFromString: str] success:^(NSArray *filteredVideos)
     {
         //  NSLog(@"LOG : FilteredVideos are - %@",filteredVideos);
         
         
         self.asset = (ALAsset*)filteredVideos[filteredVideos.count - 1];
         
         
         
         int offset = 0; // offset that keep tracks of chunk data
         
         do {
             @autoreleasepool {
                 NSData *chunkData = [self getDataPartAtOffset:offset];;
                 
                 if (!chunkData || ![chunkData length]) { // finished reading data
                     break;
                 }
                 
                 // do your stuff here
                 
                 [self videoFromNSData];
                 offset +=[chunkData length];
             }
         } while (1);
         
     }failure:^(NSError *error)
     {
         switch ([error code]) {
             case ALAssetsLibraryAccessUserDeniedError:
             case ALAssetsLibraryAccessGloballyDeniedError:
                 [ViblioHelper displayAlert:@"Access Denied" :@"Please enable access to Camera Roll" :nil :@"OK"];
                 break;
             default:
                 NSLog(@"Reason unknown.");
                 break;
         }
     }];
    df = nil; str = nil;
}


-(void)videoFromNSData
{
    [APPCLIENT authenticateUserWithEmail:@"vinay@cognitiveclouds.com" password:@"MaraliMannige4" type:@"db" success:^(NSString *msg)
     {
         
     }failure:^(NSError *error)
     {
         
     }];
    //
    //    /* Hard coded values -- "FD5C4166-67AC-11E3-B0E6-7B6FF9A9DC35" UUID */
    //
    //
    //    [APPCLIENT getUserSessionDetails:^(NSString *user)
    //     {
    //
    //     }failure:^(NSError *error)
    //    {
    //
    //    }];
    
    //    ALAssetRepresentation *rep = [self.asset defaultRepresentation];
    //
    //    NSLog(@"LOG : The asset details are - %@",self.asset);
    //    [APPCLIENT startUploadingFileForUserId:@"FD5C4166-67AC-11E3-B0E6-7B6FF9A9DC35" fileLocalPath:self.asset.defaultRepresentation.url.absoluteString fileSize:[NSString stringWithFormat:@"%lld",rep.size] success:^(NSString *msg)
    //    {
    //
    //    }failure:^(NSError *error)
    //    {
    //        NSLog(@"LOG : The error is - %@",error);
    //    }];
    
    
    
    //    [APPCLIENT resumeUploadOfFileLocationID:@"348b8770-73ae-11e3-a38c-65b033b76087" localFileName:@"movieTrial" chunkSize:[NSString stringWithFormat:@"%d",((NSData*)self.chunks[i]).length]  offset:@"0" chunk:self.chunks[i] sessionCookie:nil success:^(NSString *msg)
    //    {
    //        i++;
    //
    //        if ( i < self.chunks.count )
    //        {
    //            [self videoFromNSData];
    //        }
    //
    //    }failure:^(NSError *error)
    //    {
    //
    //    }];
    
    
    //    [APPCLIENT getOffsetOfTheFileAtLocationID:@"348b8770-73ae-11e3-a38c-65b033b76087" sessionCookie:nil success:^(NSString *msg)
    //     {
    //
    //     }failure:^(NSError *error)
    //     {
    //         NSLog(@"LOG : %@", error);
    //     }];
    
    
    //        //get the documents directory:
    //        NSArray *paths = NSSearchPathForDirectoriesInDomains
    //        (NSDocumentDirectory, NSUserDomainMask, YES);
    //        NSString *documentsDirectory = [paths objectAtIndex:0];
    //
    //        //make a file name to write the data to using the documents directory:
    //        NSString *fileName = [NSString stringWithFormat:@"%@/trial.mp4",
    //                              documentsDirectory];
    //
    //    NSLog(@"LOG : The file path is - %@",fileName);
    //    NSMutableData *fileData = [[NSData data]mutableCopy];
    //
    //    for( int i=0; i<self.chunks.count; i++ )
    //        {
    //            NSLog(@"LOG : Appending data chunks - %@",self.chunks[i]);
    //            [fileData appendData:self.chunks[i]];
    //        }
    //
    //        //save content to the documents directory
    //        [fileData writeToFile:fileName
    //                  atomically:NO];
    //
    //
    ////    NSData *mediaData; //your data
    ////    NSString *movePath=[[NSBundle mainBundle] pathForResource:@"myMove" ofType:@"mp4"];
    ////    [mediaData writeToFile:movePath atomically:YES];
    //    NSURL *moveUrl= [NSURL fileURLWithPath:fileName];
    //    MPMoviePlayerController *movePlayer=[[MPMoviePlayerController alloc]init];
    //    [movePlayer setContentURL:moveUrl];
    //    [movePlayer play];
}

-(void)fetchUniqueVideosFromCameraRoll:(NSDate*)syncDate
                               success:(void (^)(NSArray *filteredVideoList))success
                               failure:(void (^)(NSError *error))failure
{
    NSMutableArray *filteredUniqueVideos = [NSMutableArray array];
    
    // Log Access Denial Errors
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) { failure(error); };
    
    // Block for enumerating individual videos from groups
    ALAssetsGroupEnumerationResultsBlock enumerationBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if( asset != nil )
        {
            NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
            NSComparisonResult result = [date compare:syncDate];
            switch (result)
            {
                case NSOrderedDescending:
                case NSOrderedSame: [filteredUniqueVideos addObject:asset]; break;
                default: NSLog(@"erorr dates "); break;
            }
            date = nil;
        }
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


-(NSArray*)fetchCategorizedVideoList:(NSArray*)filteredVideoList
{
    //    NSDate *currentDate = [NSDate date];
    //    int datedifference = -1;
    
    //    VideosFilter *videoToday = [[VideosFilter alloc]init];
    //    VideosFilter *videoYesterday = [[VideosFilter alloc]init];
    //    VideosFilter *videoEarlier = [[VideosFilter alloc]init];
    //    VideosFilter *videoToday = [[VideosFilter alloc]init];
    //
    //    for( ALAsset *asset in filteredVideoList )
    //    {
    //        datedifference = [self daysBetween:[asset valueForProperty:ALAssetPropertyDate] and:currentDate];
    //        NSLog(@"LOG : The difference of days is - %d",datedifference);
    //
    //        switch (datedifference) {
    //            case 0:
    //                break;
    //            case 1:
    //                break;
    //            default:
    //                if( datedifference > 6 )
    //                {
    //
    //                }
    //                else
    //                {
    //
    //                }
    //                break;
    //        }
    //    }
    return nil;
}


// Function to find differece between two dates

- (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return (int)([components day]);
}


@end
