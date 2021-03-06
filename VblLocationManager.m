//
//  VblLocationManager.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 10/29/13.
//  Copyright (c) 2013 CognitiveClouds. All rights reserved.
//

#import "VblLocationManager.h"

@implementation VblLocationManager

+ (VblLocationManager *)sharedClient {
    
    static VblLocationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

- (id)init {
    
    DLog(@"Log : Init of location manger called ------------");
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    self = [super init];
    if (!self) {
        return nil;
    }
    

    return self;
}

-(BOOL)checkWhetherViblioIsAllowedToFetchLocationServices
{
    if ([CLLocationManager locationServicesEnabled] && !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) && !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) )
        return YES;
    else
        return NO;
}

-(void)setUp
{
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
}

-(void)fetchLatitudeAndLongitude
{
    NSLog(@"LOG : Updating location --------- ");
    [_locationManager startMonitoringSignificantLocationChanges];
}

-(void)stopFetchingLatitudeAndLongitude
{
    [_locationManager stopMonitoringSignificantLocationChanges];
}


-(void)presentNotification{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"Viblio Received Location Changed !!";
    localNotification.alertAction = @"Launch Viblio to resume uploads if not uploads will continue in optimal conditions";
    
    //On sound
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    DLog(@"Log : Application launched in backgorund ----- ");
    
//    if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground  )
//    {
//        [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
//    }
    
//    [self presentNotification];
    
    [DBCLIENT updateDB:^(NSString *msg)
     {
         // Clean up all the entries in the DB for those not found in the camera roll
         // DLog(@"Log : Cleaning up the entries in the DB for those not found in the camera roll....");
         //  [DBCLIENT deleteEntriesInDBForWhichNoAssociatedCameraRollRecordsAreFound];
             
         DLog(@"Log : Calling Video Manager to check if an upload was interrupted...");
         if([APPMANAGER.user.userID isValid])
             [VCLIENT videoUploadIntelligence];
         
     }failure:^(NSError *error)
     {
         DLog(@"Log : Camera roll access denied case...");
     }];
    //[VCLIENT videoUploadIntelligence];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"Log : Location manager did fail with error - %@", error);
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
//    [self presentNotification];
//    
//    [DBCLIENT updateDB:^(NSString *msg)
//     {
//         // Clean up all the entries in the DB for those not found in the camera roll
//         // DLog(@"Log : Cleaning up the entries in the DB for those not found in the camera roll....");
//         //  [DBCLIENT deleteEntriesInDBForWhichNoAssociatedCameraRollRecordsAreFound];
//         
////         if ( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
////         {
////             [UIApplication sharedApplication].applicationIconBadgeNumber = 1000;
////         }
//         
//         DLog(@"Log : Calling Video Manager to check if an upload was interrupted...");
//         if([APPMANAGER.user.userID isValid])
//             [VCLIENT videoUploadIntelligence];
//         
//     }failure:^(NSError *error)
//     {
//         DLog(@"Log : Camera roll access denied case...");
//     }];
    
//    NSLog(@"LOG : Updating the location manager callbacks");
//    CLLocation *currentLocation = newLocation;
//    if (currentLocation != nil) {
//         self.longitude = currentLocation.coordinate.longitude;
//         self.latitude = currentLocation.coordinate.latitude;
//    }
//    else
//    {
//        self.longitude = -1;
//        self.latitude = -1;
//    }
//    
//    if( self.isToSendLatLongToServer )
//    {
//        [[TLAPIClient sharedClient] sendLatitude:self.latitude andLongitude:self.longitude success:^(BOOL updated)
//         {
//             NSDictionary *locationDetails = [[NSDictionary alloc] initWithObjectsAndKeys:@(updated), @"Update", nil];
//             
//             if(updated)
//                 [TLAPIClient sharedClient].isToCaptureLocation = NO;
//             else
//                 [TLAPIClient sharedClient].isToCaptureLocation = YES;
//             
//             [[NSNotificationCenter defaultCenter] postNotificationName:TLLocationRefreshed object:nil userInfo:locationDetails];
//             locationDetails = nil;
//         }failure:^(NSError *error)
//         {
//             NSDictionary *locationDetails = [[NSDictionary alloc] initWithObjectsAndKeys:@(0), @"Update", nil];
//             [[NSNotificationCenter defaultCenter] postNotificationName:TLLocationRefreshed object:nil userInfo:locationDetails];
//             locationDetails = nil;
//             [TLAPIClient sharedClient].isToCaptureLocation = YES;
//         }];
//    }
//    [_locationManager stopUpdatingLocation];
}

-(double)getLatitude
{
    return self.latitude;
}

-(double)getLongitude
{
    return self.longitude;
}

//-(void)locationManager:(CLLocationManager *)manager
//      didFailWithError:(NSError *)error
//{
//    self.longitude = -1;
//    self.latitude = -1;
//}

//-(void)updateLocationinView :(UIView*)view
//                     success:(void (^)(BOOL locationUpdate))success
//                     failure:(void(^)(NSError *error))failure
//{
//    if( self.latitude != -1 && self.longitude != -1 )
//    {
//        [[TLAPIClient sharedClient] sendLatitude:self.latitude andLongitude:self.longitude success:^(BOOL updated)
//        {
//            success(updated);
//        }failure:^(NSError *error)
//        {
//            failure(error);
//        }];
//    }
//}

@end
