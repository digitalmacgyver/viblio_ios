//
//  Videos.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/13/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Videos : NSManagedObject

@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSNumber * sync_status;

@end