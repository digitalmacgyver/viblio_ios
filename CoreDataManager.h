//
//  CoreDataManager.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/10/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Videos.h"
#import "Session.h"

#define DBCLIENT [CoreDataManager sharedClient]

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataManager *)sharedClient;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)updateSynStatusOfFile:(NSString*)fileUrl
                 syncStatus : (NSUInteger) status;
-(void)listAllEntitiesinTheDB;
-(Videos*)listTheDetailsOfObjectWithURL:(NSString*)fileURL;
-(void)deleteOperationOnDB:(NSString*)fileURL;
-(void)deleteOperationOnDB;
-(int)getTheCountOfRecordsInDB;
-(NSArray*)fetchVideoListToBeUploaded;
-(void)updateDB;

//Video File functions
-(void)updateIsPausedStatusOfFile:(NSURL*)assetUrl forPausedState:(BOOL)isPaused;
-(void)updateFileLocationFile:(NSURL*)assetUrl toLocation:(NSString*)locationID;
-(void)updateFailStatusOfFile:(NSURL*)assetUrl toStatus:(NSNumber*)status;

// Session setting functions
-(Session*)getSessionSettings;
-(void)insertDefaultSettingsIntoSession;
-(void)updateSessionSettingsForAutoSync:(BOOL)autoSync;
-(void)updateSessionSettingsForBackgroundSync:(BOOL)backgrndSync;

@end
