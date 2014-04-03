//
//  VblLocationManager.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 10/29/13.
//  Copyright (c) 2013 CognitiveClouds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface VblLocationManager : NSObject<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property(nonatomic) double latitude, longitude;
@property(nonatomic) BOOL isToSendLatLongToServer;


+ (VblLocationManager *)sharedClient;
-(double)getLatitude;
-(double)getLongitude;
//-(void)updateLocationinView :(UIView*)view
//                     success:(void (^)(BOOL locationUpdate))success
//                     failure:(void(^)(NSError *error))failure;

-(void)setUp;
-(BOOL)checkWhetherViblioIsAllowedToFetchLocationServices;
-(void)fetchLatitudeAndLongitude;
-(void)stopFetchingLatitudeAndLongitude;

@end
