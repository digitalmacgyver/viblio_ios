//
//  CoreDataManager.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/10/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "CoreDataManager.h"

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

/* Check for DB Updates */

-(void)updateDB
{
    //[self updateSynStatusOfFile:@"assets-library://asset/asset.MOV?id=B431EADC-C4AC-48E2-B256-923F8B292056&ext=MOV" syncStatus:2];
    DLog(@"Log : Performing an update on the DB");
    [VCLIENT loadAssetsFromCameraRoll:^(NSArray *filteredVideoList)
    {
        DLog(@"Log : The contents of the array is - %@",filteredVideoList);
        
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
                        
                        NSError *error;
                        if (![[self managedObjectContext] save:&error]) {
                            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }
                        video = nil;
                        break;
                    }
                    default: DLog(@"erorr dates "); break;
                }
                date = nil;
            }
        }
        [self updateLastSyncDate];
        
    }failure:^(NSError *error) {
    }];
}

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
    return info.sync_time;
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
        DLog(@"LOG : Sync happening for the first time -----");
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Info" inManagedObjectContext:self.managedObjectContext]];
        
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        DLog(@"LOG : The updated time stamp is - %@",results);
        
        Info *info = [results firstObject];
        [info setValue:[NSDate date] forKey:@"sync_time"];
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        request = nil;
        info = nil;
        
    }
    else
    {
        DLog(@"LOg : Sync already has data ------");
        
        Info *info = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Info"
                         inManagedObjectContext:[self managedObjectContext]];
        
        info.sync_time = [NSDate date];
        NSError *error;
        if (![[self managedObjectContext] save:&error]) {
            DLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        info = nil;
    }
}

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

/*------------------------------------------------------------------------------------------*/

// List all the entities in the DB

-(void)listAllEntitiesinTheDB
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Videos"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Videos *info in fetchedObjects) {
        NSLog(@"LOG : The info object details are - %@", info);
    }
}

-(void)listTheDetailsOfObjectWithURL:(NSString*)fileURL
{
    NSFetchRequest * videos = [[NSFetchRequest alloc] init];
    [videos setEntity:[NSEntityDescription entityForName:@"Videos" inManagedObjectContext:self.managedObjectContext ]];
    [videos setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileURL == %@", fileURL];
    [videos setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * videoList = [self.managedObjectContext executeFetchRequest:videos error:&error];
    videos = nil;
    
    NSLog(@"LOG : The list obtained is as follows - %@",videoList);
    //more error handling here
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
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
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
    NSLog(@"LOG : The results obtained are - %@", results);
    
    Videos *video = [results firstObject];
    [video setValue:[NSNumber numberWithInt:status] forKey:@"sync_status"];

    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    request = nil;
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    
    NSLog(@"LOG : The app URL is - %@",[self applicationDocumentsDirectory]);
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
