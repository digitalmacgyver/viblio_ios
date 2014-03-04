//
//  CoreDataManager.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/10/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "CoreDataManager.h"
#define BLOCK_REQ_SIZE 3

@implementation CoreDataManager

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


+ (CoreDataManager *)sharedClient {
    static CoreDataManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

// Function to roll back

-(void)rollbackChanges
{
    [self.managedObjectContext rollback];
}


/* Function to return the list of videos that are to be uploaded */

-(NSArray*)fetchVideoListToBeUploaded
{
    /* We check whether there are any files for which the upload has already been started. We take such files for uploading on priority. If no
       such files are found we do take up newer files for uploading. Older files are given priority over the newer files meaning, older files will
       be synced first on priority. Blocks of 3 files will be taken for upload which means we will be making upload request for 3 files together */
    
    NSMutableArray *filteredDBSet = [self getFilteredDBEntriesBasedOnSyncStatus:1 andHasFailed:0 andIsPaused:0];
    
    if( filteredDBSet != nil && filteredDBSet.count == BLOCK_REQ_SIZE )
        return filteredDBSet;
    else
    {
        // If sufficient videos are not found then next priority is given for syncing and failed videos
        
        DLog(@"LOG : Querying DB for sync initialised failed videos to fill up the Block size");
        
        NSMutableArray *failedSyncingSet = [self getFilteredDBEntriesBasedOnSyncStatus:1 andHasFailed:1 andIsPaused:0];
        if( failedSyncingSet != nil && failedSyncingSet.count > 0 )
        {
            for( Videos *video in failedSyncingSet )
            {
                if( filteredDBSet.count < BLOCK_REQ_SIZE )
                    [filteredDBSet addObject:video];
                else
                    break;
            }
        }
        [failedSyncingSet removeAllObjects];
        failedSyncingSet = nil;
        
        if( APPMANAGER.activeSession.autoSyncEnabled )
        {
            /*------------------------------------------------------------------------------------------------*/
        
            // If sufficient videos are not found then next priority is given for non sync initialized videos
        
            if( filteredDBSet.count < BLOCK_REQ_SIZE )
            {
                DLog(@"LOG : Querying DB for non sync initialised videos to fill up the Block size");
            
                NSMutableArray *filteredNewSet = [self getFilteredDBEntriesBasedOnSyncStatus:0 andHasFailed:0 andIsPaused:0];
                if( filteredNewSet != nil && filteredNewSet.count > 0 )
                {
                    for( Videos *video in filteredNewSet )
                    {
                        if( filteredDBSet.count < BLOCK_REQ_SIZE )
                            [filteredDBSet addObject:video];
                        else
                            break;
                    }
                }
                [filteredNewSet removeAllObjects];
                filteredNewSet = nil;
            }
        }
    }
    return filteredDBSet;
}


/* Function returning the filtered DB entries based on failure, sync in progress and not initiated sync */

-(NSMutableArray*)getFilteredDBEntriesBasedOnSyncStatus : (NSUInteger)sync_status andHasFailed : (NSUInteger)hasFailed andIsPaused : (NSUInteger)isPaused
{
    NSFetchRequest * videosResultSet = [[NSFetchRequest alloc] init];
    [videosResultSet setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [videosResultSet setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    // Setting the limit of the query
    videosResultSet.fetchLimit = BLOCK_REQ_SIZE;
    
    // Sync_Status of 1 indicates that the file has already been considered for uploading
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sync_status == %d AND hasFailed = %d AND isPaused = %d", sync_status, hasFailed, isPaused];
    [videosResultSet setPredicate:predicate];
    
    // Only sort by name if the destination entity actually has a "name" field
    if ([[[[videosResultSet entity] propertiesByName] allKeys] containsObject:@"sync_time"]) {
        NSSortDescriptor *sortByTime = [[NSSortDescriptor alloc] initWithKey:@"sync_time" ascending:YES];
        [videosResultSet setSortDescriptors:[NSArray arrayWithObject:sortByTime]];
        sortByTime = nil;
    }
    
    NSError * error = nil;
    NSMutableArray * videoList = [[self.managedObjectContext executeFetchRequest:videosResultSet error:&error] mutableCopy];
    videosResultSet = nil;
    return videoList;
}


/* Check for DB Updates */

-(void)updateDB : (void(^)(NSString *msg))success
        failure : (void(^)(NSError *error)) failure
{
    DLog(@"Log : Performing an update on the DB");
    [VCLIENT loadAssetsFromCameraRoll:^(NSArray *filteredVideoList)
    {
        VCLIENT.filteredVideoList = [filteredVideoList mutableCopy];
        for( ALAsset *asset in filteredVideoList )
        {
            if( asset != nil )
            {
                NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
                NSComparisonResult result = [date compare:[self getDateOfLastSync]];
                switch (result)
                {
                    case NSOrderedDescending:
                    case NSOrderedSame:
                    {
                        DLog(@"LOG : New video found... Adding it to the DB");
                        Videos *video = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"Videos"
                                         inManagedObjectContext:[self managedObjectContext]];
                        
                        video.fileURL = [asset.defaultRepresentation.url absoluteString];
                        video.sync_status = [NSNumber numberWithInt:0];
                        video.sync_time = @([date timeIntervalSince1970]);
                        video.fileLocation = nil;
                        
                        NSError *error;
                        if (![[self managedObjectContext] save:&error]) {
                            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        video = nil;
                        break;
                    }
                    case NSOrderedAscending:
                        break;
                    default: DLog(@"erorr dates "); break;
                }
                date = nil;
            }
        }
        [self updateLastSyncDate];
        success(@"success");
        
    }failure:^(NSError *error) {
        DLog(@"Log : Error - %@", error.localizedDescription);
        failure(error);
    }];
}


// Fucntion for deletion descretion. All the entries in DB which are no more found in the camera roll should be deleted. URL is used for comparison

-(void)deleteEntriesInDBForWhichNoAssociatedCameraRollRecordsAreFound
{
    NSArray *DBEntries = [DBCLIENT listAllEntitiesinTheDB];
    for( Videos *video in DBEntries )
    {
        DLog(@"Log : The video obtained is - %@", video);
        ALAsset *asset = [VCLIENT getAssetFromFilteredVideosForUrl:video.fileURL];
        if( asset == nil )
        {
            DLog(@"Log : There is no corresponding entry for the video in Camera roll.. Delete it from DB");
            [DBCLIENT deleteOperationOnDB:video.fileURL];
        }
        else
            DLog(@"Log : Video is found in the DB");
    }
}

/*------------------------------------------------------------------------------------------- Syncing Date Related Functions --------------------------*/

-(NSDate*)getDateOfLastSync
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Info *info = [fetchedObjects firstObject];
    return [NSDate dateWithTimeIntervalSince1970:[info.sync_time floatValue]];
}


-(void)updateLastSyncDate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"Log : The earlier time stamp is - %@", results);
    
    if( [results firstObject] )
    {
        DLog(@"LOg : Sync already has data ------");
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext]];
        
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        Info *info = [results firstObject];
        [info setValue:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"sync_time"];
        
        if (![self.managedObjectContext save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        request = nil;
        info = nil;
        
    }
    else
    {
        DLog(@"LOG : Sync happening for the first time -----");
        
        Info *info = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Info"
                         inManagedObjectContext:[self managedObjectContext]];
        
        info.sync_time = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        NSError *error;
        if (![[self managedObjectContext] save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        info = nil;
    }
}

/*------------------------------------------------------------------------------------------------------------------------------------------------------*/

// Getting the count of records in DB

-(int)getTheCountOfRecordsInDB
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Videos"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects.count;
}

-(int)getTheCountOfRecordsInDBWithFileURL : (NSString*)fileURL
{
    NSFetchRequest * videos = [[NSFetchRequest alloc] init];
    [videos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [videos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", fileURL];
    [videos setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:videos error:&error];
    videos = nil;
    
    return videoList.count;
}

-(NSArray*)getTheListOfPausedVideos
{
    NSFetchRequest * videos = [[NSFetchRequest alloc] init];
    [videos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [videos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPaused == %@", @(1)];
    [videos setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:videos error:&error];
    videos = nil;
    
    return videoList;
}

-(Videos*)getWhetherAFileWithUUIDExistsInDB : (NSString*)uuid
{
    NSFetchRequest * videos = [[NSFetchRequest alloc] init];
    [videos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [videos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileUUID == %@", uuid];
    [videos setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:videos error:&error];
    videos = nil;
    
    if( videoList.count > 0 )
        return [videoList firstObject];
    else
        return nil;
}



/*------------------------------------------------------------------------------------------*/

// List all the entities in the DB

-(NSArray*)listAllEntitiesinTheDB
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Videos"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Videos *info in fetchedObjects) {
        DLog(@"LOG : %@", info);
    }
    return fetchedObjects;
}

-(Videos *)listTheDetailsOfObjectWithURL:(NSString*)fileURL
{
    NSFetchRequest * videos = [[NSFetchRequest alloc] init];
    [videos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [videos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", fileURL];
    [videos setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:videos error:&error];
    videos = nil;
    
    return [videoList firstObject];
}

// Delete operation on the DB
// Delete a single file

-(void)deleteOperationOnDB:(NSString*)fileURL
{
    NSFetchRequest * allVideos = [[NSFetchRequest alloc] init];
    [allVideos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [allVideos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", fileURL];
    [allVideos setPredicate:predicate];
    
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:allVideos error:&error];
    allVideos = nil;
    
    if([videoList firstObject])
        [self.managedObjectContext deleteObject:[videoList firstObject]];
    
    //error handling goes here
//    for (Videos * video in videoList) {
//        [self.managedObjectContext deleteObject:video];
//    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    //more error handling here
}


// Delete all the objects of the entity

-(void)deleteOperationOnDB
{
    NSFetchRequest * allVideos = [[NSFetchRequest alloc] init];
    [allVideos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [allVideos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:allVideos error:&error];
    allVideos = nil;
    
    //error handling goes here
    for (Videos * video in videoList) {
        [self.managedObjectContext deleteObject:video];
    }

    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    //more error handling here
}



// Update operation on the DB

-(void)updateSynStatusOfFile:(NSString*)fileUrl
                 syncStatus : (NSUInteger) status
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", fileUrl];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    [video setValue:[NSNumber numberWithInt:status] forKey:@"sync_status"];

    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    request = nil;
}


-(void)updateIsPausedStatusOfFile:(NSURL*)assetUrl forPausedState:(BOOL)isPaused
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", assetUrl];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    [video setValue:@(isPaused) forKey:@"isPaused"];
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    request = nil;
}

-(void)updateFileLocationFile:(NSURL*)assetUrl toLocation:(NSString*)locationID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", assetUrl];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    [video setValue:locationID forKey:@"fileLocation"];
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    request = nil;
}


-(void)updateFailStatusOfFile:(NSURL*)assetUrl toStatus:(NSNumber*)status
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", assetUrl];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    [video setValue:status forKey:@"hasFailed"];
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    request = nil;
}



-(void)updateUploadedBytesForFile:(NSURL*)assetUrl toBytes:(NSNumber*)bytes
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", assetUrl];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    DLog(@"Log : Storing uploaded bytes --- %lf", bytes.doubleValue);
    [video setValue:bytes forKey:@"uploadedBytes"];
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    request = nil;
}


-(void)updateFileUUIDForFile:(NSURL*)assetUrl withUUID : (NSString*)uuid
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", assetUrl];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    [video setValue:uuid forKey:@"fileUUID"];
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    request = nil;
}

/*************************************** Session Entity Related Functions ***************************************************/

#pragma session entity functions


-(Session*)getSessionSettings
{
    DLog(@"Log : Fetching default session settings");
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Session"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    fetchRequest = nil;
    
    if( fetchedObjects == nil )
        return nil;
    
    if( fetchedObjects != nil && fetchedObjects.count == 0 )
        return nil;
    DLog(@"Log : Fetched results- %@", fetchedObjects);
    
    return (Session*)[fetchedObjects firstObject];
}

-(void)insertDefaultSettingsIntoSession
{
    DLog(@"Log : Setting default settings for session");
    Session *sessionSettings = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Session"
                                inManagedObjectContext:[self managedObjectContext]];
    
    sessionSettings.autoSyncEnabled = @(YES);
    sessionSettings.backgroundSyncEnabled = @(YES);
    sessionSettings.wifiupload = @(NO);
    sessionSettings.autolockdisable = @(YES);
    sessionSettings.batterSaving = @(YES);
    
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    sessionSettings = nil;
}


-(void)updateSessionSettingsForKey:(NSString*)key forValue:(BOOL)value
{
    DLog(@"Log : The session setting for %@ is being updated to - %@",key, @(value));
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Session" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    Session *sessionInfo = [results firstObject];
    [sessionInfo setValue:@(value) forKey:key];
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    request = nil;
    sessionInfo = nil;
}


/**************************************** User Entity related functions *****************************************************/

#pragma user entity functions

-(void)persistUserDetailsWithEmail:(NSString*)email
                          password:(NSString*)password
                            userID:(NSString*)userID
                         isNewUser:(NSNumber*)isNewUser
                          isFbUser:(NSNumber*)isFbUser
                     sessionCookie:(NSString*)sessionCookie
                     fbAccessToken:(NSString*)fbAccessToken
                          userName:(NSString*)userName
{
    NSArray *results = [self getUserDataFromDB];
    
        NSError *deleteError;
    
        DLog(@"Log : User object already exists ------ Deleting the existing entity");
        //error handling goes here
        for (User * user in results) {
            [self.managedObjectContext deleteObject:user];
        }
        
        if (![self.managedObjectContext save:&deleteError]) {
            DLog(@"Whoops, couldn't save: %@", [deleteError localizedDescription]);
        }
    
        DLog(@"LOG : Adding the new user details to the DB");
        User *userDB = [NSEntityDescription
                      insertNewObjectForEntityForName:@"User"
                      inManagedObjectContext:[self managedObjectContext]];
        
        userDB.userID = userID;
        userDB.emailId = email;
        userDB.fbAccessToken = fbAccessToken;
        userDB.isNewUser = isNewUser;
        userDB.isFbUser = isFbUser;
        userDB.sessionCookie = sessionCookie;
        userDB.password = password;
        userDB.userName = userName;
        
        NSError *errorUserStore;
        if (![[self managedObjectContext] save:&errorUserStore]) {
            DLog(@"Whoops, couldn't save: %@", [errorUserStore localizedDescription]);
        }
        userDB = nil;
}


-(NSArray *)getUserDataFromDB
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    DLog(@"Log : The fetched user set is - %@", results);
    
    if( results != nil && results.count > 0 )
        return results;
    return nil;
}

-(void)deleteUserEntity
{
    NSFetchRequest * userResult = [[NSFetchRequest alloc] init];
    [userResult setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext ]];
    [userResult setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * userList = [self.managedObjectContext executeFetchRequest:userResult error:&error];
    userResult = nil;
    
    //error handling goes here
    for (User * user in userList) {
        [self.managedObjectContext deleteObject:user];
    }
    
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}


/*--------------------------------- Core Data Functionalities ------------------------------------------------- */

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Videos" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Videos.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
