//
//  CoreDataManager.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/10/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

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


@end
