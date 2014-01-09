//
//  ViblioClient.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ViblioClient.h"

@implementation ViblioClient

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

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (!self) {
        return nil;
    }
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        NSLog(@"LOG : Reachability of the base URL changed to - %d",status);
    }];
    
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
    
    // Initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // Setting up object mappings
    
    
    // Contents API descriptor
    RKObjectMapping *contentsMapping = [RKObjectMapping mappingForClass:[User class]];
    [contentsMapping addAttributeMappingsFromDictionary:[User mapping]];
    
    RKResponseDescriptor *userResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:contentsMapping
                                                                                               pathPattern:@"/services/na/authenticate"
                                                                                                   keyPath:@"user.uuid"
                                                                                               statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:userResponseDescriptor];
    
    
//    // Categories API descriptor
//    RKObjectMapping *categoriesMapping = [RKObjectMapping mappingForClass:[TLCategory class]];
//    [categoriesMapping addAttributeMappingsFromDictionary:[TLCategory mapping]];
//    
//    [categoriesMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contents" toKeyPath:@"contentsRated" withMapping:contentsMapping]];
//    
//    RKResponseDescriptor *categoriesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:categoriesMapping
//                                                                                                 pathPattern:@"/categories"
//                                                                                                     keyPath:@"payload.categories"
//                                                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
//    [objectManager addResponseDescriptor:categoriesResponseDescriptor];
//    
//    // Matches API descriptor
//    RKObjectMapping *matchesMapping = [RKObjectMapping mappingForClass:[TLMatch class]];
//    [matchesMapping addAttributeMappingsFromDictionary:[TLMatch mapping]];
//    
//    RKResponseDescriptor *matchesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:matchesMapping
//                                                                                              pathPattern:@"/matches"
//                                                                                                  keyPath:@"payload.matches"
//                                                                                              statusCodes:[NSIndexSet indexSetWithIndex:200]];
//    [objectManager addResponseDescriptor:matchesResponseDescriptor];
//    
//    // User API descriptor
//    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[TLUser class]];
//    [userMapping addAttributeMappingsFromDictionary:[TLUser mapping]];
//    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"categories" toKeyPath:@"categoriesRated" withMapping:categoriesMapping]];
//    
//    RKResponseDescriptor *userResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
//                                                                                           pathPattern:@"/users/:userID"
//                                                                                               keyPath:@"payload.user"
//                                                                                           statusCodes:[NSIndexSet indexSetWithIndex:200]];
//    [objectManager addResponseDescriptor:userResponseDescriptor];
//    
//    // Inbox API descriptor
//    RKObjectMapping *inboxMapping = [RKObjectMapping mappingForClass:[TLInboxMessage class]];
//    [inboxMapping addAttributeMappingsFromDictionary:[TLInboxMessage mapping]];
//    
//    RKResponseDescriptor *inboxResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:inboxMapping
//                                                                                            pathPattern:@"/inbox"
//                                                                                                keyPath:@"payload.users"
//                                                                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
//    [objectManager addResponseDescriptor:inboxResponseDescriptor];
}


#pragma User Management Services

// To login the user onto the server

- (void)authenticateUserWithEmail : (NSString*)emailID
                         password : (NSString*)password
                             type : (NSString*)loginType
                    success:(void (^)(User *user))success
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
                                      NSLog(@"LOG : result - %@",JSON);
                                      NSLog(@"LOG : response - %@", response);
                                      
                                      User *user = [[User alloc]init];
                                      user.userID = [JSON valueForKeyPath:@"user.uuid"];

                                      if( [((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"] isValid] )
                                      {
                                          NSArray *parsedSession = [((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"] componentsSeparatedByString:@";"];
                                          for ( NSString *str in parsedSession )
                                          {
                                              if( [str rangeOfString:@"va_session"].location != NSNotFound )
                                              {
                                                  NSArray *sessionParsed = [str componentsSeparatedByString:@"="];
                                                  user.sessionCookie = sessionParsed[1];
                                                  break;
                                              }
                                          }
                                      }
 
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}


- (void)authenticateUserWithFacebook : (NSString*)accessToken
                                type : (NSString*)loginType
                              success:(void (^)(User *user))success
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
                                      NSLog(@"LOG : result - %@",JSON);
                                      NSLog(@"LOG : response - %@", response);
                                      
                                      User *user = [[User alloc]init];
                                      user.userID = [JSON valueForKeyPath:@"user.uuid"];
                                      
                                      if( [((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"] isValid] )
                                      {
                                          NSArray *parsedSession = [((NSDictionary*)response.allHeaderFields)[@"Set-Cookie"] componentsSeparatedByString:@";"];
                                          for ( NSString *str in parsedSession )
                                          {
                                              if( [str rangeOfString:@"va_session"].location != NSNotFound )
                                              {
                                                  NSArray *sessionParsed = [str componentsSeparatedByString:@"="];
                                                  user.sessionCookie = sessionParsed[1];
                                                  break;
                                              }
                                          }
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
                   success:(void (^)(NSString *user))success
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
//                                      NSString *msg = [JSON valueForKeyPath:@"payload.sys_message"];
//                                      success(msg);
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
                                      //                                      NSString *msg = [JSON valueForKeyPath:@"payload.sys_message"];
                                      //                                      success(msg);
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
                                      
                                      NSLog(@"LOG : The response obtained is - %@",op.responseString);
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
                           success : (void (^)(NSString *user))success
                           failure : (void(^)(NSError *error))failure

{
    NSString *path = @"/files";
    NSDictionary *params = @{
                             @"uuid": userUUId,
                             @"file": @{
                                     @"Path": @"Sample Video.MOV"
                                     },
                             @"user-agent": @"your-client-name: your-client-version"
                             };
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:params];
    
    NSData * data = [NSPropertyListSerialization dataFromPropertyList:params
                                                               format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    NSLog(@"size: %lu --- fileSize - %@", (unsigned long)[data length], fileSize);
    
    [request setValue: fileSize  forHTTPHeaderField:@"Final-Length"];
    [request setValue: [NSString stringWithFormat:@"%lu", (unsigned long)data.length]  forHTTPHeaderField:@"Content-Length"];
    [request setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    
    
//    NSLog(@"LOG : REquest that was sent - %@ --- %@",request, );
    
    __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      
                                      
                                      NSLog(@"LOG : Response Headers - %@",response);
                                      NSLog(@"LOG : Response Body - %@",op.responseString);
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                      failure(error);
                                  }];
    [op start];
}

// Get the offset of the file

-(void)getOffsetOfTheFileAtLocationID : (NSString*)fileLocationID
                        sessionCookie : (NSString*)sessionCookie
                              success : (void (^)(NSString *user))success
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
                                      NSLog(@"LOG : The response headers is - %@", response);
                                      NSLog(@"LOG : The response body - %@",op.responseString);
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
                    success:(void (^)(NSString *user))success
                    failure:(void(^)(NSError *error))failure
{
    
    NSString *path = [NSString stringWithFormat:@"/files/%@",fileLocationID];
    NSMutableURLRequest* afRequest = [self requestWithMethod:@"PATCH" path:path parameters:nil];
    [afRequest setValue: chunkSize  forHTTPHeaderField:@"Content-Length"];
    [afRequest setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [afRequest setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [afRequest setValue: offset  forHTTPHeaderField:@"Offset"];
    [afRequest setHTTPBody:chunk];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:afRequest success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      NSLog(@"LOG : check - 2.4");
                                     // [MBProgressHUD tl_fadeOutHUDInView:view withSuccessText:@"Image saved !"];
                                      success(@"");
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                  {
                                    //  [MBProgressHUD tl_fadeOutHUDInView:view withFailureText:@"Saving image failed !"];
                                      failure(error);
                                  }];
    
    [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
//        if( totalBytesExpectedToWrite == totalBytesWritten )
//            success(@"");
    }];
    
    
    [op start];
    
    
    
    
    
//    NSMutableURLRequest *afRequest = [self multipartFormRequestWithMethod:@"PATCH" path:path parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
//                                      {
//                                          [formData appendPartWithFileData:chunk name:@"Video" fileName:fileName mimeType:@"video/mp4"];
//                                      }];
//    
//    [afRequest setValue: chunkSize  forHTTPHeaderField:@"Content-Length"];
//    [afRequest setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
//    [afRequest setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
//    [afRequest setValue: offset  forHTTPHeaderField:@"Offset"];
//
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
//     {
//         
//         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//         //success(@"");
//         //NSLog(@"uploaded percent %f", (float)totalBytesWritten/totalBytesExpectedToWrite);
//         //uploadProgress((float)(100.0*totalBytesWritten/totalBytesExpectedToWrite));
//         
//     }];
//    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response)
//     {
//         NSLog(@"AFN REST response %@", operation.responseString);
//         
//         success(@"");
//         //NSError *error;
//         //NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
//         //complete(responseData);
//         
//     }
//                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         //NSDictionary *nsDError = [NSDictionary dictionaryWithObjectsAndKeys:error.description, @"error",  [operation.response statusCode], @"statuscode", nil];
//         NSLog(@"Upload file error %@", error.description);
//         failure(error);
//         //failure(nsDError);
//     }];
//    
//    [self enqueueHTTPRequestOperation:operation];
}


@end
