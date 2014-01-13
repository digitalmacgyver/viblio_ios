//
//  Info.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/13/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Info : NSManagedObject

@property (nonatomic, retain) NSDate * sync_time;
@property (nonatomic, retain) NSNumber * gmt;

@end
