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
                APPMANAGER.turnOffUploads = YES;
                [APPCLIENT invalidateFileUploadTask];
            }
            else
                DLog(@"Log : No uploads going on to be paused by low battery status...");
        }
        else
        {
            DLog(@"Log : Battery status charged....");
            [VCLIENT videoUploadIntelligence];
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
                    DLog(@"Log : Internet reachability went off.. Pausing the upload..");
                    [ViblioHelper displayAlertWithTitle:@"Not on WiFi" messageBody:@"Uploading paused until WiFi connection established" viewController:nil cancelBtnTitle:@"OK"];
                    APPMANAGER.turnOffUploads = YES;
                    [APPCLIENT invalidateFileUploadTask];
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
                        DLog(@"Log : Wifi only upload has been set.. Cannot initiate upload on cellular data");
                }
                else
                {
                    // Wifi only upload has not been set.. Initiate upload
                    DLog(@"Log : Initating upload as no preference settings has been made..");
                    
//                    [ViblioHelper displayAlertWithTitle:@"Connection Established" messageBody:@"Internet Connection established.. Starting uploads" viewController:nil cancelBtnTitle:@"OK"];
                    
                    APPMANAGER.turnOffUploads = NO;
                    [VCLIENT videoUploadIntelligence];
                }
            }
        }
    }];
    
    self.session = [self backgroundSession];
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
    NSDictionary *queryParams = @{ @"email": emailID,
                                   @"password": password,
                                   @"realm" : loginType
                                 };
    
    NSString *path = [NSString stringWithFormat:@"/services/na/authenticate?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    NSURLRequest *req = [self requestWithMethod:@"POST" path:path parameters:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      // Check whether we got a success response or a success response with error code
                                      
                                      if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                      {
                                          DLog(@"Log : The server failed to service the login request...");
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
                                      DLog(@"LOG : response - %@", response);
                                      
                                      
                                      if( [[JSON valueForKey:@"code"] integerValue] > 299 )
                                      {
                                          DLog(@"Log : The server failed to service the login request...");
                                          failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                      }
                                      else
                                      {
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
                                          DLog(@"Log : The server failed to service the login request...");
                                          failure([ViblioHelper getCustomErrorWithMessage:[JSON valueForKey:@"message"] withCode:[[JSON valueForKey:@"code"] integerValue]]);
                                      }
                                      else
                                      {
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
                                      UserClient.userID = [JSON valueForKeyPath:@"user.uuid"];
                                      UserClient.emailId = nil;
                                      UserClient.isFbUser = @(YES);
                                      UserClient.isNewUser = @(NO);
                                      UserClient.fbAccessToken = accessToken;
                                      UserClient.sessionCookie = ((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"];
                                      
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
    NSString *path = @"/files";
    NSDictionary *params = @{
                             @"uuid": userUUId,
                             @"file": @{
                                     @"Path": @"Untitled.MOV"
                                     },
                             @"user-agent": @"Viblio iOS App : 0.0.1"
                             };
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:params];
    
    NSData * data = [NSPropertyListSerialization dataFromPropertyList:params
                                                               format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    DLog(@"size: %lu --- fileSize - %@", (unsigned long)[data length], fileSize);
    
    [request setValue: fileSize  forHTTPHeaderField:@"Final-Length"];
    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)data.length]  forHTTPHeaderField:@"Content-Length"];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    
    
//    DLog(@"LOG : REquest that was sent - %@ --- %@",request, );

    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      if( [((NSDictionary*)response.allHeaderFields)[@"Location"] isValid] )
                                      {
                                          NSArray *parsedSession = [((NSDictionary*)response.allHeaderFields)[@"Location"] componentsSeparatedByString:@"files/"];
                                          if( parsedSession != nil && parsedSession.count > 0 )
                                              success([parsedSession lastObject]);
                                      }
                                      
                                      DLog(@"LOG : Response Headers - %@",response);
                                      DLog(@"LOG : Response Body - %@",op.responseString);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}

// Get the offset of the file

-(void)getOffsetOfTheFileAtLocationID : (NSString*)fileLocationID
                        sessionCookie : (NSString*)sessionCookie
                              success : (void (^)(double offset))success
                              failure : (void(^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/files/%@",fileLocationID];
    NSMutableURLRequest* request = [self requestWithMethod:@"HEAD" path:path parameters:nil];
    
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [request setHTTPMethod:@"HEAD"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                          
                                      success([((NSDictionary*)response.allHeaderFields)[@"Offset"] doubleValue]);
                                      
                                      DLog(@"LOG : The response headers is - %@", response);
                                      DLog(@"LOG : The response body - %@",op.responseString);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
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
    
    NSString *path = [NSString stringWithFormat:@"/files/%@",fileLocationID];
    NSMutableURLRequest* afRequest = [self requestWithMethod:@"PATCH" path:path parameters:nil];
    [afRequest setValue: chunkSize  forHTTPHeaderField:@"Content-Length"];
    [afRequest setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [afRequest setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [afRequest setValue: offset  forHTTPHeaderField:@"Offset"];
//    [afRequest setHTTPBody:chunk];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/tempFile"];
    [chunk writeToFile:dataPath atomically:YES];
    
    _success = successCallback;
    _failure = failureCallback;
    self.filePath = dataPath;
    
    if( self.session == nil )
    {
        DLog(@"Log : Session might have been invalidated.. Create new session instance..");
        self.session = [self backgroundSession];
    }
    
    self.uploadTask = [self.session uploadTaskWithRequest:afRequest fromFile:[NSURL fileURLWithPath:dataPath]];
    [self.uploadTask resume];
}


#pragma session delegates

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    DLog(@"LOG : In call back handler - ");
//    if (task == self.uploadTask) {
    
    if( self.uploadTask != nil )
    {
        DLog(@"LOG : The details are as follows - bytesSent - %lld, totalBytesSent - %lld, totalBytesEpectedToSend - %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        
        self.uploadedSize += bytesSent;
        DLog(@"Log : Uploaded Size = %f", self.uploadedSize);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:refreshProgress object:nil];
    }
    else
        DLog(@"Log : Task being performed is nil");
}


- (NSURLSession *)backgroundSession {
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.viblio.BackGroundSession"];
        
        if( APPMANAGER.activeSession.wifiupload.integerValue )
        {
            configuration.allowsCellularAccess = NO;
        }
        else
        {
            configuration.allowsCellularAccess = YES;
        }
        
		session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	});
	return session;
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    // Clean the uplaoded size
    
    DLog(@"Log : Did complete called");
//    if(task != nil)
//    {
        DLog(@"Log : Not entering if");
        if (error == nil) {
            
            DLog(@"Task: %@ completed successfully", task);
            
            if([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
                [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error];
            
            if(self.uploadTask != nil)
                _success(@"");
            
        } else {
            DLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
            if(self.uploadTask != nil)
                _failure(error);
        }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    DLog(@"All tasks are finished");
}

-(void)invalidateFileUploadTask
{
    DLog(@"Log : Initialising upload Pause ----");
    
    // Upload paused by the user.... Update the user isPaused status
    
    [DBCLIENT updateIsPausedStatusOfFile:VCLIENT.asset.defaultRepresentation.url forPausedState:1];
    [self.uploadTask suspend];
    
    NSError *error = nil;
    
    if(_failure != nil)
        _failure(error);
    else
        DLog(@"Log : No existing valid instance for failure....");
}

-(void)invalidateUploadTaskWithoutPausing
{
      //  DLog(@"Log : Initialising upload Pause ----");
        
        // Upload paused by the user.... Update the user isPaused status
        
      //  [DBCLIENT updateIsPausedStatusOfFile:VCLIENT.asset.defaultRepresentation.url forPausedState:1];
    
    APPMANAGER.turnOffUploads = YES;
    [self.uploadTask suspend];
        
        NSError *error = nil;
        _failure(error);
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
                                  @"views[]": vwStyle };
    
    NSString *path = [NSString stringWithFormat:@"/services/mediafile/list?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [request setValue: APPMANAGER.user.sessionCookie  forHTTPHeaderField:@"Cookie"];
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                          ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              DLog(@"Log : In success response callback - Feedback - %@", JSON);
                                              
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
                                                      video.url = [videoObj valueForKey:@"views"][@"poster"][@"url"];
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
                                                  DLog(@"Log : The cloud video list now is - %@", VCLIENT.cloudVideoList);
                                                  
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


-(void)getListOfSharedWithMeVideos :(void(^)(NSArray *sharedList))success
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
                                              
                                              // Create an array that holds the resultant parsed sharedVideo Objects to be sent as success response
                                              NSMutableArray *sharedVideoList = [NSMutableArray new];
                                              
                                              // List of all shared
                                              NSArray *array = (NSArray*)[JSON valueForKeyPath:@"shared"] ;
                                              
                                              // Iterating through list of all shared
                                              for( int i = 0; i < array.count; i++ )
                                              {
                                                  NSDictionary *videoValues = [array objectAtIndex:i];
                                                  NSArray *videoBySpecificOwner = videoValues[@"media"];
                                                  
                                                  NSString *ownerName = videoValues[@"owner"][@"displayname"];
                                                  NSString *ownerUUID = videoValues[@"owner"][@"uuid"];
                                                  
                                                  // Media list of the specific owner
                                                  for( int i = 0; i < videoBySpecificOwner.count; i++ )
                                                  {
                                                      SharedVideos *video = [[SharedVideos alloc]init];
                                                      NSDictionary *mediaObj = (NSDictionary*)[videoBySpecificOwner objectAtIndex:i];
                                                      video.createdDate = mediaObj[@"created_date"];
                                                      video.sharedDate = mediaObj[@"shared_date"];
                                                      video.mediaUUID = mediaObj[@"uuid"];
                                                      video.viewCount = mediaObj[@"view_count"] ;
                                                      video.posterURL = mediaObj[@"views"][@"poster"][@"url"];
                                                      video.ownerName = ownerName;
                                                      video.ownerUUID = ownerUUID;
                                                      
                                                      // Add the video object to the resultant array list
                                                      [sharedVideoList addObject:video];
                                                      video = nil;
                                                      mediaObj = nil;
                                                  }
                                              }
                                              
                                              // Send the list of result objects back in the success response
                                              success(sharedVideoList);
                                              
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
   // NSString *emailList = APPMANAGER.selectedContacts; //[APPMANAGER.selectedContacts componentsJoinedByString:@","]; //[[NSString alloc]init];
    //emailList = [emailList str];
    
    if([title isValid] && [title isEqualToString:@"Title"])
        title = @"Untitled";
        
    
    NSMutableArray *email = [NSMutableArray new];
    //DLog(@"Log : The email list is - %@", email);
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
    
    DLog(@"Log : The email list being sent is - %@", email);
    
    __block AFJSONRequestOperation *op;
    if( email != nil && email.count > 0 )
    {
        NSDictionary *queryParams = @{
                                      @"title" : title,
                                        @"mid" : mid,
                                        @"subject" : subject,
                                        @"body" : body,
                                        @"list" : [email componentsJoinedByString:@","]
                                     };
        
        NSString *path = [NSString stringWithFormat:@"/services/mediafile/add_share?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
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
@end
