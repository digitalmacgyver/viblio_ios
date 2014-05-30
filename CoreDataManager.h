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
-(NSArray*)listAllEntitiesinTheDB;
-(Videos*)listTheDetailsOfObjectWithURL:(NSString*)fileURL;
-(void)deleteOperationOnDB:(NSString*)fileURL;
-(void)deleteOperationOnDB;
-(int)getTheCountOfRecordsInDB;
-(NSArray*)fetchVideoListToBeUploaded;
-(void)updateDB : (void(^)(NSString *msg))success
        failure : (void(^)(NSError *error)) failure;

//Video File functions
-(void)updateIsPausedStatusOfFile:(NSURL*)assetUrl forPausedState:(BOOL)isPaused;
-(void)updateFileLocationFile:(NSURL*)assetUrl toLocation:(NSString*)locationID;
-(void)updateFailStatusOfFile:(NSURL*)assetUrl toStatus:(NSNumber*)status;
-(void)updateUploadedBytesForFile:(NSURL*)assetUrl toBytes:(NSNumber*)bytes;
-(void)updateIsCompletedStatusOfFile:(NSURL*)assetUrl forCompletedState:(BOOL)isCompleted;
-(NSArray*)listAllEntitiesinTheDBWithCompletedStatus : (NSInteger)isCompleted;
-(NSArray*)getTheListOfPausedVideos;
-(Videos*)getWhetherAFileWithUUIDExistsInDB : (NSString*)uuid;
-(void)updateFileUUIDForFile:(NSURL*)assetUrl withUUID : (NSString*)uuid;
-(void)deleteEntriesInDBForWhichNoAssociatedCameraRollRecordsAreFound : (void(^)(NSString *msg))success
                                                              failure : (void(^)(NSError *error)) failure;

// Session setting functions
-(Session*)getSessionSettings;
-(void)insertDefaultSettingsIntoSession;
-(void)updateSessionSettingsForKey:(NSString*)key forValue:(BOOL)value;

// User related functions
-(void)persistUserDetailsWithEmail:(NSString*)email
                          password:(NSString*)password
                            userID:(NSString*)userID
                         isNewUser:(NSNumber*)isNewUser
                          isFbUser:(NSNumber*)isFbUser
                     sessionCookie:(NSString*)sessionCookie
                     fbAccessToken:(NSString*)fbAccessToken
                          userName:(NSString*)userName;
-(NSArray *)getUserDataFromDB;
-(void)deleteUserEntity;


-(void)rollbackChanges;

@end
