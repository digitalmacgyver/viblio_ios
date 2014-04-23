//
//  AppManager.h
//  Viblio_v2
//
//  Created by Vinay on 1/18/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Session.h"
#import "cloudVideos.h"
#import "SharedVideos.h"

#define APPMANAGER [AppManager sharedClient]

@interface AppManager : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Session *activeSession;
@property (nonatomic, strong) NSArray *listVideos;
@property (nonatomic) BOOL turnOffUploads;
@property (nonatomic, strong) NSMutableArray *contacts, *selectedContacts, *loadContacts, *tempContacts;
//@property (nonatomic, strong) cloudVideos *video;
@property (nonatomic, strong) NSDictionary *resultCategorized, *sharedSortedList;
@property (nonatomic, strong) UIImage *posterImageForVideoSharing;
@property (nonatomic, strong) id VideoToBeShared;
@property (assign) BOOL restoreMyViblio, internetNotAvailable;

@property (nonatomic, strong) NSMutableArray *orderedKeys, *sharedOrderedKeys, *sharedOwnerOrderedKeys ;
@property (nonatomic, assign) int errorCode ;
@property (nonatomic, assign) NSIndexPath *indexOfSharedListSelected;

@property (nonatomic, assign) AFNetworkReachabilityStatus signalStatus;
@property (nonatomic, strong) NSMutableArray *sharedVideoList;

+ (AppManager *)sharedClient;
-(NSArray*)getSettings;
-(NSDictionary*)getSessionKeysAndValues;
-(NSArray*)getSectionsList;

@end
