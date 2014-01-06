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

#pragma User Management Services

// To login the user onto the server

- (void)authenticateUserWithEmail : (NSString*)emailID
                         password : (NSString*)password
                             type : (NSString*)loginType
                    success:(void (^)(NSString *user))success
                    failure:(void(^)(NSError *error))failure
{
    NSDictionary *queryParams = @{ @"email": emailID,
                                   @"password": password,
                                   @"realm" : loginType
                                 };
    
    NSString *path = [NSString stringWithFormat:@"/services/na/authenticate?%@",[ViblioHelper stringBySerializingQueryParameters:queryParams]];
    NSURLRequest *req = [self requestWithMethod:@"GET" path:path parameters:nil];
    
   __block AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:
                                  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                  {
                                      NSLog(@"LOG : The response is - %@ - body - %@",response, [op responseString]);
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
                                     @"PATH": fileLocalPath
                                     },
                             @"user-agent": @"your-client-name: your-client-version"
                             };
    
    NSMutableURLRequest* request = [self requestWithMethod:@"POST" path:path parameters:params];
    
    NSData * data = [NSPropertyListSerialization dataFromPropertyList:params
                                                               format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    NSLog(@"size: %d --- fileSize - %@", [data length], fileSize);
    
    [request setValue: fileSize  forHTTPHeaderField:@"Final-Length"];
    [request setValue: [NSString stringWithFormat:@"%d", data.length]  forHTTPHeaderField:@"Content-Length"];
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
    NSMutableURLRequest *afRequest = [self multipartFormRequestWithMethod:@"PATCH" path:path parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:chunk name:@"Video" fileName:fileName mimeType:@"video/mp4"];
                                      }];
    
    [afRequest setValue: chunkSize  forHTTPHeaderField:@"Content-Length"];
    [afRequest setValue: @"application/offset+octet-stream"  forHTTPHeaderField:@"Content-Type"];
    [afRequest setValue: sessionCookie  forHTTPHeaderField:@"Cookie"];
    [afRequest setValue: offset  forHTTPHeaderField:@"Offset"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
     {
         
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
         success(@"");
         //NSLog(@"uploaded percent %f", (float)totalBytesWritten/totalBytesExpectedToWrite);
         //uploadProgress((float)(100.0*totalBytesWritten/totalBytesExpectedToWrite));
         
     }];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response)
     {
         NSLog(@"AFN REST response %@", operation.responseString);
         //NSError *error;
         //NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
         //complete(responseData);
         
     }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //NSDictionary *nsDError = [NSDictionary dictionaryWithObjectsAndKeys:error.description, @"error",  [operation.response statusCode], @"statuscode", nil];
         NSLog(@"Upload file error %@", error.description);
         //failure(nsDError);
     }];
    
    [self enqueueHTTPRequestOperation:operation];
}


@end
