//
//  Videos.h
//  Viblio_v2
//
//  Created by Vinay on 1/21/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Videos : NSManagedObject

@property (nonatomic, retain) NSString * fileLocation;
@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSNumber * hasFailed;
@property (nonatomic, retain) NSNumber * isPaused;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSNumber * sync_time;
@property (nonatomic, retain) NSNumber * uploadedBytes;
@property (nonatomic, retain) NSString * fileUUID;

@end
