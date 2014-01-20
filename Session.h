//
//  Session.h
//  Viblio_v2
//
//  Created by Vinay on 1/19/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Session : NSManagedObject

@property (nonatomic, retain) NSNumber * autoSyncEnabled;
@property (nonatomic, retain) NSNumber * backgroundSyncEnabled;

@end
