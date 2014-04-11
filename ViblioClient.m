//
//  ViblioClient.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ViblioClient.h"

@implementation ViblioClient

void(^_success)(NSString *user);
void(^_failure)(NSError *error);

+ (ViblioClient *)sharedClient {
    static ViblioClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:API_LOGIN_SERVER_URL]];
        //let AFNetworking manage the activity indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        [_sharedClient setDefaultHeader:@"Accept" value:@"text/xml"];
    });
    
    return _sharedClient;
}

- (DataModel *)dataModel
{
    if (!_dataModel)
    {
        _dataModel = [[DataModel alloc] init];
    }
    
    return _dataModel;
}

// Battery status notification handler
- (void)batteryChanged:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    DLog(@"state: %i | charge: %f", device.batteryState, device.batteryLevel);
    
    if( APPMANAGER.activeSession.batterSaving.integerValue )
    {
        if( device.batteryLevel < 0.2 )
        {
            DLog(@"Log : Battery low.. Stop uploads...");
            
            if( VCLIENT.asset != nil )
            {
                APPMANAGER.errorCode = 1000;
                APPMANAGER.turnOffUploads = YES;
                [APPCLIENT invalidateFileUploadTask];
            }
            else
                DLog(@"Log : No uploads going on to be paused by low battery status...");
        }
        else
        {
            NSArray *userResults = [DBCLIENT getUserDataFromDB];
            if( userResults != nil && userResults.count > 0 )
            {
                DLog(@"Log : Battery status charged....");
                [VCLIENT videoUploadIntelligence];
            }
            else
                DLog(@"Log : Valid user session does not exist.... ");

        }
    }
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (!self) {
        return nil;
    }
    
    // Set up lsteners for battery level change
    
    
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryLevelDidChangeNotification" object:device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:device];
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        DLog(@"LOG : Reachability of the base URL changed to - %d",status);
        APPMANAGER.signalStatus = status;
        
        // Check whether a valid user session exists. Then check whether wifi only upload has been set as the preference.
        if( [APPMANAGER.user.userID isValid] )
        {
            DLog(@"Log : Valid user session exists");
            
            // Check whether the reachability to the remote server exists or not
            if( status == 0 )
            {
                // Check whether an upload is going on. If so then show an alert to the user.
                
                if( VCLIENT.asset !=  nil )
                {
                    APPMANAGER.errorCode = 1001;
                    DLog(@"Log : Internet reachability went off.. Pausing the upload..");
                    
                    if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive )
                    {
                        [ViblioHelper displayAlertWithTitle:@"Not Connected" messageBody:@"Internet is my life and you dont seem to be connected. Connect  to help me upload videos quick." viewController:nil cancelBtnTitle:@"OK"];
                    }

                    APPMANAGER.turnOffUploads = YES;
                    [APPCLIENT invalidateUploadTaskWithoutPausing];
                    //[APPCLIENT invalidateFileUploadTask];
                }
            }
            else
            {
                // Check if the wifi only upload setting has been enabled
                if( APPMANAGER.activeSession.wifiupload.integerValue )
                {
                    // If wifi only upload has been enabled then check whether reachability is over wifi
                    if( status == 2 )
                    {
                        DLog(@"Log : Reachable over wifi");
                        
                       // [ViblioHelper displayAlertWithTitle:@"Connection Established" messageBody:@"WiFi Connection established.. Starting uploads" viewController:nil cancelBtnTitle:@"OK"];
                        
                        APPMANAGER.turnOffUploads = NO;
                        [VCLIENT videoUploadIntelligence];
                    }
                    else
                    {
                        DLog(@"Log : Wifi only upload has been set.. Cannot initiate upload on cellular data");
                        if( VCLIENT.asset != nil )
                        {
                            [APPCLIENT invalidateUploadTaskWithoutPausing];
                            APPMANAGER.turnOffUploads = YES;
                            
                            if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive )
                            {
                                [ViblioHelper displayAlertWithTitle:@"Not on WiFi" messageBody:@"Uploading paused until WiFi connection established" viewController:nil cancelBtnTitle:@"OK"];
                            }

                        }
                    }
                }
                else
                {
                    // Wifi only upload has not been set.. Initiate upload
                    DLog(@"Log : Initating upload as no preference settings has been made..");
                    
                    APPMANAGER.turnOffUploads = NO;
                    [VCLIENT videoUploadIntelligence];
                }
            }
        }
    }];
    
    //self.session = [self backgroundSession];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    return self;
}


- (void)setupRestKit
{
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
    
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize HTTPClient
    NSURL *baseURL = [NSURL URLWithString:API_LOGIN_SERVER_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    //we want to work with JSON-Data
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
}


#pragma User Management Services

// To login the user onto the server

- (void)authenticateUserWithEmail : (NSString*)emailID
                         password : (NSString*)password
                             type : (NSString*)loginType
                    success:(void (^)(NSString *msg))success
                    failure:(void(^)(NSError *error))failure
{
    NSLog(@"Log : Checkpoint - 1 ");
    
    
    
    
    NSDictionary *queryParams = @{ @"email": emailID,
                                   @"password": password,
                                   @"realm" : loginType
                                 };
    
    NSLog(@"Log : Checkpoint - 1.1 ");
    
    NSString *path = [NSString stringWithFormat:@"/services/na/authenticate?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    
    NSLog(@"Log : Checkpoint - 1.2 ");
    
    NSURLRequest *req = [self requestWithMethod:@"POST" path:path parameters:nil];
    
    NSLog(@"Log : Checkpoint - 1.3 ");
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      // Check whether we got a success response or a success response with error code
                                      
                                      if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                      {
                                          DLog(@"Log : The server failed to service the login request... - %@", JSON);
                                          
                                          if( [JSON[@"detail"] isEqualToString:@"NOLOGIN_NOT_IN_BETA"] )
                                              failure([ViblioHelper getCustomErrorWithMessage:@"uh oh!  looks like the email or password you entered is incorrect" withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                          else
                                              failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                      }
                                      else
                                      {
                                          DLog(@"Log : The result obtained is - %@", JSON);
                                          
                                          UserClient.userName = [JSON valueForKeyPath:@"user.displayname"];
                                          UserClient.userID = [JSON valueForKeyPath:@"user.uuid"];
                                          UserClient.emailId = emailID;
                                          UserClient.isFbUser = @(NO);
                                          UserClient.isNewUser = @(NO);
                                          UserClient.sessionCookie = ((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"];
                                        
                                          success(@"Success");
                                      }
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}


- (void)authenticateUserWithFacebook : (NSString*)accessToken
                                type : (NSString*)loginType
                              success:(void (^)(NSString *msg))success
                              failure:(void(^)(NSError *error))failure
{
    NSDictionary *queryParams = @{ @"access_token": accessToken,
                                   @"realm" : loginType
                                 };
    
    NSString *path = [NSString stringWithFormat:@"/services/na/authenticate?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    NSURLRequest *req = [self requestWithMethod:@"POST" path:path parameters:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      DLog(@"LOG : result - %@",JSON);
                                      
                                      if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                      {
                                          
                                          if( [JSON[@"detail"] isEqualToString:@"NOLOGIN_NOT_IN_BETA"] )
                                              failure([ViblioHelper getCustomErrorWithMessage:@"uh oh!  looks like the email or password you entered is incorrect" withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                          else
                                              failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                      }
                                      else
                                      {
                                          UserClient.userName = JSON[@"user"][@"displayname"];
                                          UserClient.userID = [JSON valueForKeyPath:@"user.uuid"];
                                          UserClient.emailId = nil;
                                          UserClient.isFbUser = @(YES);
                                          UserClient.isNewUser = @(NO);
                                          UserClient.fbAccessToken = accessToken;
                                          UserClient.sessionCookie = ((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"];
                                          
                                          success(@"Success");
                                      } 
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}

// To create a new user account

- (void)createNewUserAccountWithEmail : (NSString *)emailID
                             password : (NSString*)password
                          displayName : (NSString*)displayName
                                 type : (NSString*)loginType
                   success:(void (^)(NSString *msg))success
                   failure:(void(^)(NSError *error))failure
{
    
    NSDictionary *queryParams = @{ @"email": emailID,
                                   @"password": password,
                                   @"displayname" : displayName,
                                   @"realm" : loginType
                                 };
    
    NSString *path = [NSString stringWithFormat:@"/services/na/new_user?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    NSURLRequest *req = [self requestWithMethod:@"GET" path:path parameters:nil];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      // Check whether we got a success response or a success response with error code
                                      
                                      if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                      {
                                          if( [JSON[@"detail"] isEqualToString:@"NOLOGIN_NOT_IN_BETA"] )
                                              failure([ViblioHelper getCustomErrorWithMessage:@"uh oh!  looks like the email or password you entered is incorrect" withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                          else
                                              failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                          
//                                          DLog(@"Log : The server failed to service the login request...");
//                                          failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                      }
                                      else
                                      {
                                          UserClient.userName = displayName;
                                          UserClient.userID = [JSON valueForKeyPath:@"user.uuid"];
                                          UserClient.emailId = emailID;
                                          UserClient.isFbUser = @(NO);
                                          UserClient.isNewUser = @(YES);
                                          UserClient.sessionCookie = ((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"];
                                          
                                          success(@"success");
                                      }
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}


- (void)createNewUserAccountWithFB : (NSString *)accessToken
                              type : (NSString*)loginType
                            success:(void (^)(NSString *user))success
                            failure:(void(^)(NSError *error))failure
{
    NSDictionary *queryParams = @{ @"access_token": accessToken,
                                   @"realm" : loginType
                                 };
    
    NSString *path = [NSString stringWithFormat:@"/services/na/new_user?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    NSURLRequest *req = [self requestWithMethod:@"GET" path:path parameters:nil];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                      {
                                          
                                          if( [JSON[@"detail"] isEqualToString:@"NOLOGIN_NOT_IN_BETA"] )
                                              failure([ViblioHelper getCustomErrorWithMessage:@"uh oh!  looks like the email or password you entered is incorrect" withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                          else
                                              failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                      }
                                      else
                                      {
                                          UserClient.userName = JSON[@"user"][@"displayname"];
                                          UserClient.userID = [JSON valueForKeyPath:@"user.uuid"];
                                          UserClient.emailId = nil;
                                          UserClient.isFbUser = @(YES);
                                          UserClient.isNewUser = @(NO);
                                          UserClient.fbAccessToken = accessToken;
                                          UserClient.sessionCookie = ((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"];
                                      }
                                      
                                      success(@"Success");
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}

// To raise a request for forgot password

-(void)passwordForgot : (NSString*)emailId
              success : (void(^)(NSString *msg))success
              failure : (void(^)(NSError *error))failure
{
    DLog(@"Log : Raising request for password forgot");
    

        NSString *path = @"/services/na/forgot_password_request";
        NSDictionary *params = @{
                                 @"email": emailId
                                 };
        NSURLRequest *req = [self requestWithMethod:@"POST" path:path parameters:params];
        
        __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                              ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                              {
                                                  DLog(@"LOG : The response obtained is - %@",op.responseString);
                                                  success(@"");
                                                  
                                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                              {
                                                  failure(error);
                                              }];
        [op start];
}


// To check whether a valid session is running on the server

- (void)getUserSessionDetails : (void (^)(NSString *user))success
                      failure : (void(^)(NSError *error))failure
{
    NSString *path = @"/services/user/me";
    NSURLRequest *req = [self requestWithMethod:@"GET" path:path parameters:nil];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
//                                      NSString *msg = [JSON valueForKeyPath:@"payload.sys_message"];
//                                      success(msg);
                                      
                                      DLog(@"LOG : The response obtained is - %@",op.responseString);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}

#pragma Upload File Services

// Start uploading a new file

-(void)startUploadingFileForUserId : (NSString*)userUUId
                     fileLocalPath : (NSString*)fileLocalPath
                          fileSize : (NSString*)fileSize
                           success : (void (^)(NSString *fileLocation))success
                           failure : (void(^)(NSError *error))failure

{
    NSDictionary *params = @{
                             @"uuid": userUUId,
                             @"file": @{
                                     @"Path": @"Untitled.MOV"
                                     },
                             @"user-agent": @"Viblio iOS App : 0.0.1"
                             };
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://staging.viblio.com/files"]]; //[self requestWithMethod:@"POST" path:path parameters:params];
    [request setHTTPMethod:@"POST"];
    
    NSString *file = [NSString stringWithFormat:@"{\n\"Path\" : \"Untitled.MOV\"}"];
    
    
    NSString *jsonString = [NSString stringWithFormat:@"{ \n \"uuid\" : \"%@\" , \n \"file\" : %@ , \n \"user-agent\" : \"Viblio iOS App : 0.0.1\"   }", userUUId, file];
    NSData *myJSONData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData * data = [NSPropertyListSerialization dataFromPropertyList:params
                                                                format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    DLog(@"size: %lu --- fileSize - %@", (unsigned long)[data length], fileSize);
    
    [request setHTTPBody:myJSONData];
    [request setValue: fileSize  forHTTPHeaderField:@"Final-Length"];
    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)data.length]  forHTTPHeaderField:@"Content-Length"];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];

    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      if( [((NSDictionary*)response.allHeaderFields)[@"Location"] isValid] )
                                      {
                                          NSArray *parsedSession = [((NSDictionary*)response.allHeaderFields)[@"Location"] componentsSeparatedByString:@"files/"];
                                          if( parsedSession != nil && parsedSession.count > 0 )
                                              success([parsedSession lastObject]);
                                      }
                                      else
                                          failure(nil);

                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}




-(void)startUploadingFileInBackgroundForUserId : (NSString*)userUUId
                     fileLocalPath : (NSString*)fileLocalPath
                          fileSize : (NSString*)fileSize
                           success : (void (^)(NSString *fileLocation))success
                           failure : (void(^)(NSError *error))failure
{
    bgTask = [[UIApplication sharedApplication]
              beginBackgroundTaskWithExpirationHandler:
              ^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                 // [((AppDelegate*)[UIApplication sharedApplication].delegate) presentNotification];
              }];
    
    NSDictionary *params = @{
                             @"uuid": APPMANAGER.user.userID,
                             @"file": @{
                                     @"Path": @"Untitled.MOV"
                                     },
                             @"user-agent": @"Viblio iOS App : 0.0.1"
                             };
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://staging.viblio.com/files"]];
    [request setHTTPMethod:@"POST"];
    NSString *file = [NSString stringWithFormat:@"{\n\"Path\" : \"Untitled.MOV\"}"];
    NSString *jsonString = [NSString stringWithFormat:@"{ \n \"uuid\" : \"%@\" , \n \"file\" : %@ , \n \"user-agent\" : \"Viblio iOS App : 0.0.1\"   }", APPMANAGER.user.userID, file];
    
    NSData *myJSONData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSPropertyListSerialization dataFromPropertyList:params
                                                               format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    DLog(@"size: %lu --- fileSize - %lld", (unsigned long)[data length], VCLIENT.asset.defaultRepresentation.size);
    
    [request setHTTPBody:myJSONData];
    [request setValue: [NSString stringWithFormat:@"%lld", VCLIENT.asset.defaultRepresentation.size]  forHTTPHeaderField:@"Final-Length"];
    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)data.length]  forHTTPHeaderField:@"Content-Length"];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    
    NSHTTPURLResponse  *response = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    
    DLog(@"Log : Ther esponse string is - %@", response);

    if( [((NSDictionary*)response.allHeaderFields)[@"Location"] isValid] )
    {
        NSArray *parsedSession = [((NSDictionary*)response.allHeaderFields)[@"Location"] componentsSeparatedByString:@"files/"];
        if( parsedSession != nil && parsedSession.count > 0 )
            success([parsedSession lastObject]);
    }
    else
        failure(nil);
    
    
    if (bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}




// Get the offset of the file

-(void)getOffsetOfTheFileAtLocationID : (NSString*)fileLocationID
                        sessionCookie : (NSString*)sessionCookie
                              success : (void (^)(NSNumber *offset))success
                              failure : (void(^)(NSError *error))failure
{

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://staging.viblio.com/files/%@",fileLocationID ]]]; //[self requestWithMethod:@"HEAD" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [request setHTTPMethod:@"HEAD"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      DLog(@"Log : Checkpoint- 1");
                                      success( (NSNumber*)((NSDictionary*)response.allHeaderFields)[@"Offset"] );
                                      DLog(@"LOG : The response headers is - %@", response);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      DLog(@"Log : Checkpoint- 1.1");
                                      failure(error);
                                  }];
    [op start];
}


-(void)getOffsetOfTheFileInBackgroundAtLocationID : (NSString*)fileLocationID
                        sessionCookie : (NSString*)sessionCookie
                              success : (void (^)(NSNumber *offset))success
                              failure : (void(^)(NSError *error))failure
{
    
    bgTask = [[UIApplication sharedApplication]
              beginBackgroundTaskWithExpirationHandler:
              ^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
              }];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://staging.viblio.com/files/%@",fileLocationID ]]]; //[self requestWithMethod:@"HEAD" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [request setHTTPMethod:@"HEAD"];
    
    NSError *error;
    
    NSHTTPURLResponse  *response = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    
    DLog(@"Log : Ther esponse string is - %@", response);

    if( error == nil )
    {
        success( (NSNumber*)((NSDictionary*)response.allHeaderFields)[@"Offset"] );
    }
    else
        failure(error);
    
    if (bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}


// Sending a PATCH request to the file with the offset and file location ID

- (void)resumeUploadOfFileLocationID : (NSString*)fileLocationID
                    localFileName : (NSString*)fileName
                        chunkSize : (NSString*)chunkSize
                           offset : (NSString*)offset
                            chunk : (NSData*)chunk
                    sessionCookie : (NSString*)sessionCookie
                    success:(void (^)(NSString *user))successCallback
                    failure:(void(^)(NSError *error))failureCallback
{
    
    if( VCLIENT.isBkgrndTaskEnded == YES )
    {
//        if( VCLIENT.bgTask != UIBackgroundTaskInvalid )
//        {
//            DLog(@"Log : Cleaning up other background tasks before creating new one....");
//            [[UIApplication sharedApplication] endBackgroundTask:VCLIENT.bgTask];
//            VCLIENT.bgTask = UIBackgroundTaskInvalid;
//        }
        
        DLog(@"Log : New bkground task being created......");
        VCLIENT.isBkgrndTaskEnded = NO;
         VCLIENT.bgTask = [[UIApplication sharedApplication]
                          beginBackgroundTaskWithExpirationHandler:
                          ^{
                              
                              [[UIApplication sharedApplication] endBackgroundTask:VCLIENT.bgTask];
                              VCLIENT.bgTask = UIBackgroundTaskInvalid;
                              //bgTask = -1;
                              VCLIENT.isBkgrndTaskEnded = YES;
                              
                              if( VCLIENT.asset != nil )
                              {
                                  DLog(@"Log : Have to show the notification.......");
                                  
                                  if( ! VCLIENT.notifcationShown )
                                  {
                                      [((AppDelegate*)[UIApplication sharedApplication].delegate) presentNotification];
                                      VCLIENT.notifcationShown = YES;
                                  }
                              }
                              
                          }];
//    }

//    NSTimer *bckGrndTime = [NSTimer scheduledTimerWithTimeInterval:150 target:self selector:@selector(startNewBckgrndTask) userInfo:nil repeats:NO];
//    if( ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) && offset == 0 )
//    {
//        DLog(@"Log : Application state background.... Registering for background operation");
//        
//        bgTask = [[UIApplication sharedApplication]
//                  beginBackgroundTaskWithExpirationHandler:
//                  ^{
//                      [[UIApplication sharedApplication] endBackgroundTask:bgTask];
//                  }];
//        
    }
    
  //  bckgrndTimer = [NSTimer scheduledTimerWithTimeInterval:175 target:self selector:@selector(cleanBackgrndTasks) userInfo:nil repeats:NO];
    
   // NSString *path = [NSString stringWithFormat:@"/files/%@",fileLocationID];
    NSMutableURLRequest* afRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://staging.viblio.com/files/%@",fileLocationID ]]]; //[self requestWithMethod:@"PATCH" path:path parameters:nil];
    [afRequest setHTTPMethod:@"PATCH"];
    [afRequest setValue: chunkSize  forHTTPHeaderField:@"Content-Length"];
    [afRequest setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [afRequest setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [afRequest setValue: offset  forHTTPHeaderField:@"Offset"];
    [afRequest setHTTPBody:chunk];
    
//    NSError *error;
//    
//    NSHTTPURLResponse  *response = nil;
    
     AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:afRequest success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      NSLog(@"LOG : check - 2.4");
                                      
                                      
                                      
                                      successCallback(@"");
                                     // DLog(@"Log : --- %@", JSON);
                                      // [MBProgressHUD tl_fadeOutHUDInView:view withSuccessText:@"Image saved !"];
                                     // success([JSON valueForKeyPath:@"payload.picture_id"]);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      DLog(@"Log : ----- %@", error);
                                     // [MBProgressHUD tl_fadeOutHUDInView:view withFailureText:@"Saving image failed !"];
                                      failureCallback(error);
                                  }];
    
    [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
      //  NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        // 32 Kb added call back
        
        if(totalBytesWritten != totalBytesExpectedToWrite)
            self.uploadedSize = totalBytesWritten;
        
//        if( [UIApplication sharedApplication].backgroundTimeRemaining > 175 )
//        {
//            [((AppDelegate*)[UIApplication sharedApplication].delegate) presentNotification];
//            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
//            bgTask = UIBackgroundTaskInvalid;
//        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:refreshProgress object:nil];
        
//        if( totalBytesWritten == totalBytesExpectedToWrite )
//        {
//            successCallback(@"");
//        }
        
        //if(  )

    }];
    
    self.uploadRequest = op;
    [op start];
    
    
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:afRequest delegate:self];
//    
//    [conn start];
//    [NSURLConnection sendAsynchronousRequest:afRequest queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//     {
//         DLog(@"Log : %@ -- %@", response, data);
//         if ([data length] > 0 && error == nil){
//             //[self receivedData:data];
//         }else if ([data length] == 0 && error == nil){
//             //[self emptyReply];
//         }else if (error != nil && error.code == NSURLErrorTimedOut){ //used this NSURLErrorTimedOut from foundation error responses
//             //[self timedOut];
//         }else if (error != nil){
//             //[self downloadError:error];
//         }
//     }];
    
    
    
//    [NSURLConnection sendAsynchronousRequest:afRequest queue:nil
//                                      error:&error];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
//    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/tempFile"];
//    [chunk writeToFile:dataPath atomically:YES];
    
    _success = successCallback;
    _failure = failureCallback;
//    self.filePath = dataPath;
    
    
    
//    if( self.session == nil )
//    {
//        DLog(@"Log : Session might have been invalidated.. Create new session instance..");
//        self.session = [self backgroundSession];
//    }
    
//    if( self.uploadTask.state != NSURLSessionTaskStateSuspended )
//    {
//        self.uploadTask = [self.session uploadTaskWithRequest:afRequest fromFile:[NSURL fileURLWithPath:dataPath]];
//        [self.uploadTask resume];
//    }
//    else
//    {
//        DLog(@"Log : ------------------------------*****************/////// The upload task is suspended ///////..........*****************");
//        [self.uploadTask resume];
//    }
//    
//    DLog(@"Log : The location of the file uploaded is - %@", VCLIENT.videoUploading.fileLocation);
//    DLog(@"Log : The task id of the current performing task is - %d", self.uploadTask.taskIdentifier);
    
//    if( ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) && offset == 0 )
//    {
//        DLog(@"Log : Application state background....");
//        if (bgTask != UIBackgroundTaskInvalid)
//        {
//            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
//            bgTask = UIBackgroundTaskInvalid;
//        }
//    }
}


-(void)cleanBackgrndTasks
{
    DLog(@"Log : Clening the background task before the app crashes.....");
    if( VCLIENT.bgTask != UIBackgroundTaskInvalid )
    {
        DLog(@"Log : Cleaning up other background tasks before creating new one....");
        
        [((AppDelegate*)[UIApplication sharedApplication].delegate) presentNotification];
        [[UIApplication sharedApplication] endBackgroundTask:VCLIENT.bgTask];
        VCLIENT.bgTask = UIBackgroundTaskInvalid;
    }
    
    [bckgrndTimer invalidate];
    bckgrndTimer = nil;
}


-(void)startNewBckgrndTask
{
    DLog(@"Log : New Background upload task ----");
    
}


//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    // The request is complete and data has been received
//    // You can parse the stuff in your instance variable now
//    DLog(@"Log : Connection is - %@", connection);
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    // The request has failed for some reason!
//    // Check the error var
//    DLog(@"Log : Error is - %@", error);
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    DLog(@"Log : Response received is - %@", response);
//}
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    DLog(@"Log : The data obtained is - %@", data);
//    DLog(@"Log : The string is - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//}
//
//
//
//#pragma download delegates
//
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
//    
//    
//    NSLog(@"Session %@ download task %@ finished downloading to URL %@\n",
//          session, downloadTask, location);
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//
//    NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:@"response.tmp"];
//    
//    if ([fileManager fileExistsAtPath:txtPath] == YES) {
//        [fileManager removeItemAtPath:txtPath error:&error];
//    }
//    
//    NSError *moveError;
//    
//    if( [fileManager moveItemAtPath:[location path] toPath:txtPath error:&moveError] )
//    {
//        NSError *err = nil;
//        NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location
//                                                               error: &err];
//        DLog(@"Log : The data in the file is - %@", [fh readDataToEndOfFile] );
//
//    }
//    else
//    {
//        DLog(@"Log : Error while moving and the error is - %@", moveError);
//    }
//    
//    
//    
//    
//    
////
////   // NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"response" ofType:@"txt"];
////    [fileManager mov:[location path] toPath:txtPath error:&error];
////    
////    NSError* fileError = nil;
////   // NSString *path = [[NSBundle mainBundle] pathForResource: @"foo" ofType: @"html"];
////    NSString *res = [NSString stringWithContentsOfFile: txtPath encoding:NSUTF8StringEncoding error: &fileError];
////    DLog(@"Log : The result is - %@", res);
//    
//    
////#if 0
////    /* Workaround */
////    [self callCompletionHandlerForSession:session.configuration.identifier];
////#endif
////    
////#define READ_THE_FILE 0
////#if READ_THE_FILE
////    /* Open the newly downloaded file for reading. */
////    NSError *err = nil;
////    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location
////                                                           error: &err];
////    /* Store this file handle somewhere, and read data from it. */
////    // ...
////    
////#else
////    NSError *err = nil;
////    NSFileManager *fileManager = [NSFileManager defaultManager];
////    NSString *cacheDir = [[NSHomeDirectory()
////                           stringByAppendingPathComponent:@"Library"]
////                          stringByAppendingPathComponent:@"Caches"];
////    NSURL *cacheDirURL = [NSURL fileURLWithPath:cacheDir];
////    
////    NSError *error;
////    
////    if ([fileManager fileExistsAtPath:[cacheDirURL path]] == YES) {
////        DLog(@"Log :File exists and file is being removed -------");
////        [fileManager removeItemAtPath:[cacheDirURL path] error:&error];
////    }
////    
////    if ([fileManager moveItemAtURL:location
////                             toURL:cacheDirURL
////                             error: &err]) {
////        
////        NSError *err = nil;
////        NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location
////                                                               error: &err];
////        DLog(@"Log : The data in the file is - %@", [fh readDataToEndOfFile] );
////
////        /* Store some reference to the new URL */
////    } else {
////        /* Handle the error. */
////        DLog(@"Error occured while moving and the error is - %@", err);
////        
////       // fileManager removeItemAtURL:<#(NSURL *)#> error:<#(NSError *__autoreleasing *)#>
////    }
////#endif

    
//#if 0
//    /* Workaround */
//    [self callCompletionHandlerForSession:session.configuration.identifier];
//#endif
//    
//#define READ_THE_FILE 1
//#if READ_THE_FILE
//    /* Open the newly downloaded file for reading. */
//    NSError *err = nil;
//    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location
//                                                           error: &err];
//    NSData *data = [fh readDataToEndOfFile];
//    
//    DLog(@"Log : The nsdata obtained from the file is - %@", data);
//    NSError* error;
//    NSDictionary* json = [NSJSONSerialization
//                          JSONObjectWithData:data
//                          options:kNilOptions
//                          error:&error];
//    
//    DLog(@"Log : The json string obtained is - %@", json);
//    
//#else
//    NSError *err = nil;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *cacheDir = [[NSHomeDirectory()
//                           stringByAppendingPathComponent:@"Library"]
//                          stringByAppendingPathComponent:@"Caches"];
//    NSURL *cacheDirURL = [NSURL fileURLWithPath:cacheDir];
//    if ([fileManager moveItemAtURL:location
//                             toURL:cacheDirURL
//                             error: &err]) {
//        
//        /* Store some reference to the new URL */
//    } else {
//        /* Handle the error. */
//    }
//#endif
//
//}

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    
//    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
//          session, downloadTask, fileOffset, expectedTotalBytes);
//    
//}
//
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
//
//    DLog(@"Log : total bytes written - %lld , total bytes expected - %lld", totalBytesWritten, totalBytesExpectedToWrite);
//    //    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
////    
////    dispatch_async(dispatch_get_main_queue(), ^{
////        [self.progressView setProgress:progress];
////    });
//}




//#pragma session delegates
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//   didSendBodyData:(int64_t)bytesSent
//    totalBytesSent:(int64_t)totalBytesSent
//totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
//{
//    DLog(@"LOG : In call back handler - ");
////    if (task == self.uploadTask) {
//    
//    if( self.uploadTask != nil )
//    {
//        DLog(@"LOG : The details are as follows - bytesSent - %lld, totalBytesSent - %lld, totalBytesEpectedToSend - %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
//        
//        self.uploadedSize += bytesSent;
//        DLog(@"Log : Uploaded Size = %f", self.uploadedSize);
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:refreshProgress object:nil];
//    }
//    else
//        DLog(@"Log : Task being performed is nil");
//}
//
//
//
//- (NSURLSession *)backgroundSession {
//	static NSURLSession *session = nil;
////	static dispatch_once_t onceToken;
////	dispatch_once(&onceToken, ^{
//		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.viblio.BackGroundSession"];//backgroundSessionConfiguration:@"com.viblio.BackGroundSession"];
//        
//        if( APPMANAGER.activeSession.wifiupload.integerValue )
//        {
//            configuration.allowsCellularAccess = NO;
//        }
//        else
//        {
//            configuration.allowsCellularAccess = YES;
//        }
//        
//		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
////	});
//	return session;
//}
//
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    
//    // Clean the uplaoded size
//    
//    DLog(@"Log : Did complete called");
////    if(task != nil)
////    {
////        DLog(@"Log : Not entering if");
//        if (error == nil) {
//            
//            DLog(@"Task: %@ completed successfully", task);
//            
//            if([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
//                [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error];
//            
//            if( ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) && VCLIENT.backgroundStartChunk < 0 )
//            {
//                VCLIENT.backgroundStartChunk = 1;
//            }
//            
//            if(self.uploadTask != nil)
//                _success(@"");
//            
//        } else {
//            DLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
//            if(self.uploadTask != nil)
//                _failure(error);
//        }
//}
//
//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (appDelegate.backgroundSessionCompletionHandler) {
//        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
//        appDelegate.backgroundSessionCompletionHandler = nil;
//        completionHandler();
//    }
//    DLog(@"All tasks are finished");
//}
//
//- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
//{
//    DLog(@"Log : Session did get inavlidated.. %@", error);
//}
////- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
////{
////    DLog(@"Log : Did receive challenge.... %@", challenge);
////}
//
//
//-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
////    if (_sessionFailureCount == 0) {
//    
//  //  Class_get
//    
//    DLog(@"Log : Did receive challenge.... %@ -- %@, protection Space - %@ , proposedCredential - %@, sender - %@", challenge, challenge.error, challenge.protectionSpace,challenge.proposedCredential, challenge.sender);
// 
//    DLog(@"Log : Cred for trust is - %@", [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
//    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
//    
//    
//    id <NSURLAuthenticationChallengeSender> sender = challenge.sender;
//    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
//    
//    SecTrustRef trust = protectionSpace.serverTrust;
//    DLog(@"Log : The trust is - %@", trust);
//    [sender useCredential:[NSURLCredential credentialForTrust:trust] forAuthenticationChallenge:challenge];
//    
////    if ([challenge previousFailureCount] > 0) {
////        [[challenge sender] cancelAuthenticationChallenge:challenge];
////        NSLog(@"Bad Username Or Password");
////      //  badUsernameAndPassword = YES;
////      //  finished = YES;
////        return;
////    }
//    
////    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
////    {
////        
////        SecTrustResultType result;
////        //This takes the serverTrust object and checkes it against your keychain
////        SecTrustEvaluate(challenge.protectionSpace.serverTrust, &result);
////        
//////        if (appDelegate._allowInvalidCert)
//////        {
//////            [challenge.sender useCredential:
//////             [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust]
//////                 forAuthenticationChallenge: challenge];
//////        }
////        //When testing this against a trusted server I got kSecTrustResultUnspecified every time. But the other two match the description of a trusted server
//////        else if( result == kSecTrustResultUnspecified){
////            [challenge.sender useCredential:
////             [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust]
////                 forAuthenticationChallenge: challenge];
////        }
////        else
////        {
////            //Asks the user for trust
////            TrustGenerator *tg = [[TrustGenerator alloc] init];
////            
////            if ([tg getTrust:challenge.protectionSpace])
////            {
////                
////                //May need to add a method to add serverTrust to the keychain like Firefox's "Add Excpetion"
////                [challenge.sender useCredential:
////                 [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust]
////                     forAuthenticationChallenge: challenge];
////            }
////            else {
////                [[challenge sender] cancelAuthenticationChallenge:challenge];
////            }
////        }
////    }
////    else if ([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodDefault) {
////        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceNone];
////        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
////    }
//
//    //    NSArray *trustedHosts = [NSArray arrayWithObjects:@"mytrustedhost",nil];
////    
////    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
////        DLog(@"Log : Entering into the challenge added part");
////        if ([trustedHosts containsObject:challenge.protectionSpace.host]) {
////            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
////        }
////    }
////    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//    
////    DLog(@"Log : Did receive challenge.... %@ -- %@, protection Space - %@ , proposedCredential - %@", challenge, challenge.error, challenge.protectionSpace,challenge.proposedCredential);
////    DLog(@"Log : The credentials being sent on the challenge is - %@ - %@", APPMANAGER.user.emailId, APPMANAGER.user.password);
////    NSURLCredential *cred = [NSURLCredential credentialWithUser:APPMANAGER.user.emailId password:APPMANAGER.user.password persistence:NSURLCredentialPersistenceForSession];
////    completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
////        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
////    } else {
////        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
////    }
////    _sessionFailureCount++;
//}
////
////
////- (void)URLSession:(NSURLSession *)session didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
////    
////    DLog(@"Log : received authentication challenge.....");
////    NSArray *trustedHosts = [NSArray arrayWithObjects:@"mytrustedhost",nil];
////    
////    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
////        if ([trustedHosts containsObject:challenge.protectionSpace.host]) {
////            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
////        }
////    }
////    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
////}
////
////
////- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
////didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
//// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,    NSURLCredential *credential))completionHandler
////{
////    DLog(@"Log : Did receive challenge.... %@ -- %@", challenge, challenge.error);
//////    if (_taskFailureCount == 0) {
////    
//////    DLog(@"Log : The credentials being sent on the challenge is - %@ - %@", APPMANAGER.user.emailId, APPMANAGER.user.password);
//////    
//////    [challenge.sender useCredential:
//////     [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust]
//////         forAuthenticationChallenge: challenge];
////
////
////    
//////        NSURLCredential *cred = [NSURLCredential credentialWithUser:APPMANAGER.user.emailId password:APPMANAGER.user.password persistence:NSURLCredentialPersistenceNone];
//////        completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
//////    } else {
//////        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
//////    }
//////    _taskFailureCount++;
////}
////
////- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
////{
////    DLog(@"Log : Task now requires new body stream to send to the server");
////}
//
//-(BOOL) shouldTrustProtectionSpace :(NSURLProtectionSpace*)protectionSpace
//{
//    // Load the certificate
//    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"viblio" ofType:@"der"];
//    NSData *certData = [[NSData alloc]initWithContentsOfFile:certPath];
//    CFDataRef certDataRef = (__bridge_retained CFDataRef)certData;
//    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
//    
//    //Establish a chain of trust anchored on our bundled certificate
//    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void*)&cert, 1, NULL);
//    SecTrustRef serverTrust = protectionSpace.serverTrust;
//    SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
//    
//    //Verify that trust
//    SecTrustResultType trustResult;
//    SecTrustEvaluate(serverTrust, &trustResult);
//    
//    // Fix if result is a recoverable trust failure
//    if( trustResult == kSecTrustResultRecoverableTrustFailure )
//    {
//        CFDataRef errDataRef = SecTrustCopyExceptions(serverTrust);
//        SecTrustSetExceptions(serverTrust, errDataRef);
//        SecTrustEvaluate(serverTrust, &trustResult);
//    }
//    
//    DLog(@"Log : Sec trust returned is - %u", trustResult);
//    return trustResult == kSecTrustResultUnspecified || kSecTrustResultProceed ;
//}




-(void)invalidateFileUploadTask
{
    DLog(@"Log : Initialising upload Pause ----");
    
    // Upload paused by the user.... Update the user isPaused status
    
    [DBCLIENT updateIsPausedStatusOfFile:VCLIENT.asset.defaultRepresentation.url forPausedState:1];
    //VCLIENT.asset = nil;
    //self.uploadTask = nil;
   // [self.uploadTask suspend];
    
   // VCLIENT.isToBePaused = YES;
    [self.uploadRequest cancel];
    
//    if( self.uploadTask.state == NSURLSessionTaskStateSuspended )
//    {
//        DLog(@"Log : ---------------************ Task suspended for paused file ************------------");
//        DLog(@"Log : Tsk id of the suspended task is - %d", self.uploadTask.taskIdentifier);
//    }
    
//    DLog(@"Log : Task id of the suspended task is - %d", self.uploadTask.taskIdentifier);
//    DLog(@"Log : Tha state of the task is - %d", self.uploadTask.state);
//    
    //DLog(@"Log : The state of the uploadtask is - %@", self.uploadTask.state);
 
    //self.session = nil;
    //[self.session invalidateAndCancel];
    
//    NSError *error = nil;
    
    DLog(@"Log : Hitting the failure callback now---------------------------------");
    if(_failure != nil)
        _failure(nil);
//    else
//        DLog(@"Log : No existing valid instance for failure....");
}

-(void)invalidateUploadTaskWithoutPausing
{
        DLog(@"Log : Cancelling upload Without Pause ----");
        
        // Upload paused by the user.... Update the user isPaused status
        
      //  [DBCLIENT updateIsPausedStatusOfFile:VCLIENT.asset.defaultRepresentation.url forPausedState:1];
    
    //APPMANAGER.turnOffUploads = YES;
    DLog(@"Log : Initialising upload Pause ---- 1");
//    [self.uploadTask cancel];
     DLog(@"Log : Initialising upload Pause ---- 2");
//        NSError *error = nil;
    [self.uploadRequest cancel];
    
    if( _failure != nil )
        _failure(nil);
//    else
//        DLog(@"Log : Failure call back not found....");
}


#pragma media APIs

// API to get the count of media files uploaded by the user

-(void)getCountOfMediaFilesUploadedByUser:(void(^)(int count))success
                                 failure : (void (^) (NSError *error))failure
{
    NSString *path = @"/services/mediafile/count";
//    NSDictionary *params = @{
//                             @"uuid": APPMANAGER.user.userID
//                             };
    
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              //success(2);
                                              DLog(@"Log : %@", JSON);
                                              success(((NSString*)([JSON valueForKeyPath:@"count"])).integerValue);
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


// The below web service checks for the validity of the email. It also tells the clien whether  email has already been taken by any other user on Viblio


-(void)checkWhetherEmailIsValid:(NSString*)emailId
                        success:(void(^)(BOOL status))success
                        failure:(void(^)(NSError *error))failure
{
    DLog(@"Log : Checking for the validity of the email address - %@", emailId);
    NSString *path = @"/services/na/valid_email";
    NSDictionary *params = @{
                             @"email" : emailId
                             };
    
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" path:path parameters:params];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback");
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
    
}


-(void)fetchTermsAndConditions:(void(^)(NSString *terms))success
                        failure:(void(^)(NSError *error))failure
{
    DLog(@"Log : Fetching Viblio terms of use....");
    NSString *path = @"/services/na/terms";
    
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Terms and Conditions - %@", JSON);
                                              success([JSON valueForKey:@"terms"]);
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
    
}


-(void)sendFeedbackToServerWithText:(NSString*)text
                          category : (NSString*)categorySelected
                    success:(void(^)(NSString *msg))success
                    failure:(void(^)(NSError *error))failure

{
    DLog(@"Log : Sending feedback to the server");
   
    NSDictionary *params = @{ @"feedback" : text,
                              @"feedback_email" : @"feedback@support.viblio.com",
                              @"feedback_location" : [NSString stringWithFormat:@"Dashboard : %@", categorySelected]};
    NSString *path = [NSString stringWithFormat:@"/services/na/form_feedback?%@", [ViblioHelper stringBySerializingQueryParameters:params]];
    params = nil;

    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              success(@"");
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


// Web service to fetch the list of media files of the logged in user

-(void)getTheListOfMediaFilesOwnedByUserWithOptions : (NSString*)vwStyle
                                          pageCount : (NSString*)page
                                               rows : (NSString*)rowsInAPage
                                  success:(void(^)(NSMutableArray *result))success
                                  failure:(void(^)(NSError *error))failure
{
    
    NSDictionary *queryParams = @{ @"page" : page,
                                   @"rows" : rowsInAPage,
                                  @"views[]": vwStyle,
                                   @"include_tags" : @"0",
                                   @"include_shared" : @"1",
                                   @"include_contact_info" : @"1"};
    
    NSString *path = [NSString stringWithFormat:@"/services/mediafile/list?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                         //     DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              
                                              if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                                  failure([ViblioHelper getCustomErrorWithMessage:@"Session Epired. Please Login" withCode:401]);
                                              else
                                              {
                                                  NSArray *videoList = [JSON valueForKeyPath:@"media"];
                                                  NSMutableArray *result = [NSMutableArray new];
                                                  for( int i=0; i < videoList.count; i++ )
                                                  {
                                                      NSDictionary *videoObj = [videoList objectAtIndex:i];
                                                      cloudVideos *video = [[cloudVideos alloc]init];
                                                      video.uuid = [videoObj valueForKey:@"uuid"];
                                                      
                                                      if( (videoObj[@"views"][@"face"] != nil) && ((NSArray*)videoObj[@"views"][@"face"]).count > 0  )
                                                      {
                                                          video.faces = videoObj[@"views"][@"face"];
                                                      }

                                                      video.shareCount = ((NSNumber*)videoObj[@"shared"]).intValue;
                                                      
                                                      id poster = [videoObj valueForKey:@"views"][@"poster"];
                                                      
                                                      if( [poster isKindOfClass:[NSDictionary class]] ||  [poster isKindOfClass:[NSMutableDictionary class]])
                                                          video.url = poster[@"url"];
                                                      else if ( [poster isKindOfClass:[NSArray class]] ||  [poster isKindOfClass:[NSMutableArray class]] )
                                                          video.url = [poster firstObject][@"url"];
                                                      
                                                      video.createdDate = [videoObj valueForKey:@"recording_date"];
                                                      
                                                      NSString *lat = [videoObj valueForKey:@"lat"];
                                                      NSString *longitude = [videoObj valueForKey:@"lng"];
                                                      
                                                      if( ![lat isEqual:[NSNull null]] && [lat isValid] )
                                                          video.lat = lat;
                                                      
                                                      if( ![lat isEqual:[NSNull null]] && [longitude isValid] )
                                                          video.longitude = longitude;

                                                      [result addObject:video];
                                                      videoObj = nil; video = nil;
                                                      lat = longitude = nil;
                                                  }
                                                  videoList = nil;
                                                  success(result);
                                              }

                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


-(void)getTheCloudUrlForVideoStreamingForFileWithUUID : (NSString*)uuid
                                               success:(void(^)(NSString *cloudURL))success
                                               failure:(void(^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/services/mediafile/cf?mid=%@",uuid];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              success(JSON[@"url"]);
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


-(void)getListOfSharedWithMeVideos :(void(^)(NSMutableArray *sharedList))success
                            failure:(void(^)(NSError *error))failure
{
    
    NSString *path = @"/services/mediafile/all_shared";
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Feedback - %@", JSON);

                                              success(JSON[@"shared"]);
                                              
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


-(void)streamAvatarsImageForUUID : (NSString*)uuid
                          success:(void(^)(UIImage *profileImage))success
                          failure:(void(^)(NSError *error))failure
{
    
    NSDictionary *queryParams = @{@"uid" : uuid,
                                  @"x" : @"-",
                                   @"y" : @"60"
                                   };

    NSString *path = [NSString stringWithFormat:@"/services/na/avatar?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"GET" path:path parameters:nil];
    [request setValue: @"image/png"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: @"image/png"  forHTTPHeaderField:@"Accept"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *err){
        if (!err && data) {
            DLog(@"Log : The data obtained is - %@", data);
            success([UIImage imageWithData:data]);
        }
    }];
}


// API call for getting the list of faces in a media file

-(void)getFacesInAMediaFileWithUUID : (NSString*)uuid
                             success:(void(^)(NSArray *faceList))success
                             failure:(void(^)(NSError *error))failure
{
    DLog(@"Log : Gettin the Faces from non authenticated web service...");
    
    NSString *path = [NSString stringWithFormat:@"/services/na/faces_in_mediafile?mid=%@",uuid];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                             // DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              NSMutableArray *faces = [[NSMutableArray alloc]init];
                                              NSArray *result = JSON[@"faces"];
                                              if( JSON[@"faces"] == nil || ((NSArray*)JSON[@"faces"]).count <= 0 )
                                              {
                                                  DLog(@"Log : Returning array as it is..");
                                                  faces = nil; result = nil;
                                                  success(JSON[@"faces"]);
                                              }
                                              else
                                              {
                                                  // There are faces identified.. Parse them to get the URL
                                                  
                                                  DLog(@"Log : Parsing faces");
                                                  for( NSDictionary *faceValues in result )
                                                  {
                                                      if( [faceValues[@"url"] isValid] )
                                                         [faces addObject:faceValues[@"url"]];
                                                  }
                                                  success(faces);
                                              }
                                              
                                              
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
    
}


// API call for getting the address with given lat and long

-(void)getAddressWithLat : (NSString*)latitude andLong : (NSString*)longitude
                  success:(void(^)(NSString *formattedAddress))success
                  failure:(void(^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/services/na/geo_loc?lat=%@&lng=%@",latitude, longitude];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              //DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              success([JSON firstObject][@"formatted_address"]);
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


// API call to know whether a media file has ever been shared by the user

-(void)hasAMediaFileBeenSharedByTheUSerWithUUID : (NSString*)uuid
                                         success:(void(^)(BOOL hasBeenShared))success
                                         failure:(void(^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/services/mediafile/has_been_shared?mid=%@",uuid];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              //BOOL isShared = NO;
                                              
                                              if( ((NSString*)[JSON valueForKeyPath:@"count"]).integerValue )
                                                  success(YES);
                                              else
                                                  success(NO);
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


-(AFJSONRequestOperation*)sharingToUsersWithSubject : (NSString*)subject
                                              title : (NSString*) title
                            body : (NSString*)body
                          fileId : (NSString*)mid
                            success : (void(^)(BOOL hasBeenShared))success
               failure:(void(^)(NSError *error))failure
{
    if([title isValid] && [title isEqualToString:@"Title"])
        title = @"Untitled";
        
    
    NSMutableArray *email = [NSMutableArray new];
    for( int i=0; i < APPMANAGER.selectedContacts.count; i++ )
    {
        NSDictionary *selectedContct = APPMANAGER.selectedContacts[i];
        
        if( selectedContct[@"email"] != nil && ((NSArray*)selectedContct[@"email"]).count > 0 )
        {
            for( int j=0; j< ((NSArray*)selectedContct[@"email"]).count; j++ )
            {
                [email addObject: ((NSArray*)selectedContct[@"email"])[j]];
            }
        }
    }
    
  //  [email addObject:@"dunty.vinay@gmail.com"];
    
    __block AFJSONRequestOperation *op;
    if( email != nil && email.count > 0 )
    {
        
        NSString *encodedSubject = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL,
                                                                                      (CFStringRef)subject,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8 ));
        
        NSString *encodedBody = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                         NULL,
                                                                                                         (CFStringRef)body,
                                                                                                         NULL,
                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                         kCFStringEncodingUTF8 ));
        
        NSString *emailList = @"";
        for(NSString *emailid in email)
        {
            emailList = [emailList stringByAppendingString:[NSString stringWithFormat:@"list[]=%@&", emailid]];
        }
        emailList = [emailList substringToIndex:emailList.length-1];
        
        NSString *path = [NSString stringWithFormat:@"/services/mediafile/add_share?title=%@&mid=%@&subject=%@&body=%@&%@",title, mid, encodedSubject, encodedBody, emailList];

        NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
                      
        [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
        [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
        
        DLog(@"Log : The request being sent is - %@", request);
        op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                              ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                              {
                                                  success(YES);
                                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                              {
                                                  failure(error);
                                              }];
        [op start];
    }
    else
        failure([ViblioHelper getCustomErrorWithMessage:@"No contacts found in Address Book" withCode:1003]);
    return op;
}


-(AFJSONRequestOperation*)tellAFriendAboutViblioWithMessage : (NSString*)msg
                                 success : (void(^)(BOOL hasBeenTold))success
                                 failure : (void(^)(NSError *error))failure
{
    NSMutableArray *email = [NSMutableArray new];
    for( int i=0; i < APPMANAGER.selectedContacts.count; i++ )
    {
        NSDictionary *selectedContct = APPMANAGER.selectedContacts[i];
        
        if( selectedContct[@"email"] != nil && ((NSArray*)selectedContct[@"email"]).count > 0 )
        {
            for( int j=0; j< ((NSArray*)selectedContct[@"email"]).count; j++ )
            {
                [email addObject: ((NSArray*)selectedContct[@"email"])[j]];
            }
        }
    }
    
  //  [email addObject:@"dunty.vinay@gmail.com"];
    
    __block AFJSONRequestOperation *op;
    if( email != nil && email.count > 0 )
    {
        
        NSString *encodedSubject = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                         NULL,
                                                                                                         (CFStringRef)msg,
                                                                                                         NULL,
                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                         kCFStringEncodingUTF8 ));
        NSString *emailList = @"";
        for(NSString *emailid in email)
        {
            emailList = [emailList stringByAppendingString:[NSString stringWithFormat:@"list[]=%@&", emailid]];
        }
        emailList = [emailList substringToIndex:emailList.length-1];
        NSString *path = [NSString stringWithFormat:@"/services/user/tell_a_friend?message=%@&%@", encodedSubject, emailList];
        
        
//        NSDictionary *queryParams = @{
//                                      @"message" : msg,
//                                      @"list" : [email componentsJoinedByString:@","]
//                                      };
        
//        NSString *path = [NSString stringWithFormat:@"/services/user/tell_a_friend?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
        NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
        [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
        [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
        
        op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
              ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
              {
                  DLog(@"Log : In success response callback - Feedback - %@", JSON);
                  success(YES);
              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
              {
                  failure(error);
              }];
        [op start];
    }
    else
        failure([ViblioHelper getCustomErrorWithMessage:@"No contacts found in Address Book" withCode:1003]);
    return op;
}

-(void)deleteTheFileWithID : (NSString*)fileLocation
                   success : (void(^)(BOOL hasBeenDeleted))success
                   failure : (void(^)(NSError *error))failure
{
    bgTask = [[UIApplication sharedApplication]
              beginBackgroundTaskWithExpirationHandler:
              ^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
              }];
    
    NSString *path = [NSString stringWithFormat:@"/files/%@",fileLocation];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"DELETE" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              success(YES);

                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
    
    if (bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}


-(AFJSONRequestOperation*)postDeviceTokenToTheServer : (NSString*)deviceToken
                          success : (void(^)(NSString *msg))success
                          failure : (void(^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/services/user/add_device?network=APNS&deviceid=%@",deviceToken];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              success(@"");
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
    return op;
}


-(void)clearBadge : (NSString*)deviceToken
                          success : (void(^)(NSString *msg))success
                          failure : (void(^)(NSError *error))failure
{
    
    
    NSString *path = [NSString stringWithFormat:@"/services/user/clear_badge?network=APNS&deviceid=%@",deviceToken];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              success(@"");
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}

-(void)getMetadataOfTheMediaFileWithUUID : (NSString*)uuid
                                 success : (void(^)(cloudVideos *mediaObj))success
                                 failure : (void(^)(NSError *error))failure
{
   // uuid = @"1f6e8f60-ba56-11e3-970c-ffeeadd61129";
    NSDictionary *queryParams = @{
                                  @"mid" : uuid,
                                   @"views[]": @"poster",
                                   @"include_tags" : @"0",
                                   @"include_shared" : @"1",
                                   @"include_contact_info" : @"1"};
    NSString *path = [NSString stringWithFormat:@"/services/mediafile/get?%@", [ViblioHelper stringBySerializingQueryParameters:queryParams]];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              //success(@"");
                                              DLog(@"Log : The result is - %@", JSON);
                                              NSDictionary *videoObj = JSON[@"media"];
                                              
                                              cloudVideos *video = [[cloudVideos alloc]init];
                                              video.uuid = [videoObj valueForKey:@"uuid"];
                                              
                                              if( (videoObj[@"views"][@"face"] != nil) && ((NSArray*)videoObj[@"views"][@"face"]).count > 0  )
                                              {
                                                  video.faces = videoObj[@"views"][@"face"];
                                              }
                                              video.shareCount = ((NSNumber*)videoObj[@"shared"]).intValue;
                                              
                                              id poster = [videoObj valueForKey:@"views"][@"poster"];
                                              
                                              if( [poster isKindOfClass:[NSDictionary class]] ||  [poster isKindOfClass:[NSMutableDictionary class]])
                                                  video.url = poster[@"url"];
                                              else if ( [poster isKindOfClass:[NSArray class]] ||  [poster isKindOfClass:[NSMutableArray class]] )
                                                  video.url = [poster firstObject][@"url"];
                                              
                                              video.createdDate = [videoObj valueForKey:@"recording_date"];
                                              
                                              NSString *lat = [videoObj valueForKey:@"lat"];
                                              NSString *longitude = [videoObj valueForKey:@"lng"];
                                              
                                              if( ![lat isEqual:[NSNull null]] && [lat isValid] )
                                                  video.lat = lat;
                                              
                                              if( ![lat isEqual:[NSNull null]] && [longitude isValid] )
                                                  video.longitude = longitude;
                                              
                                              success(video);
                                              
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              failure(error);
                                          }];
    [op start];
}


@end
