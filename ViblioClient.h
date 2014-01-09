//
//  ViblioClient.h
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#define APPCLIENT [ViblioClient sharedClient]
#define APPAUTH [AuthControllers sharedInstance]

@interface ViblioClient : AFHTTPClient

+ (ViblioClient *)sharedClient;

- (void)authenticateUserWithEmail : (NSString*)emailID
                         password : (NSString*)password
                             type : (NSString*)loginType
                           success:(void (^)(User *user))success
                           failure:(void(^)(NSError *error))failure;


- (void)authenticateUserWithFacebook : (NSString*)accessToken
                             type : (NSString*)loginType
                           success:(void (^)(User *user))success
                           failure:(void(^)(NSError *error))failure;


- (void)createNewUserAccountWithEmail : (NSString *)emailID
                             password : (NSString*)password
                          displayName : (NSString*)displayName
                                 type : (NSString*)loginType
                               success:(void (^)(NSString *user))success
                               failure:(void(^)(NSError *error))failure;


- (void)getUserSessionDetails : (void (^)(NSString *user))success
                      failure : (void(^)(NSError *error))failure;


-(void)startUploadingFileForUserId : (NSString*)userUUId
                     fileLocalPath : (NSString*)fileLocalPath
                          fileSize : (NSString*)fileSize
                           success : (void (^)(NSString *user))success
                           failure : (void(^)(NSError *error))failure;


-(void)getOffsetOfTheFileAtLocationID : (NSString*)fileLocationID
                        sessionCookie : (NSString*)sessionCookie
                              success : (void (^)(NSString *user))success
                              failure : (void(^)(NSError *error))failure;


- (void)resumeUploadOfFileLocationID : (NSString*)fileLocationID
                       localFileName : (NSString*)fileName
                           chunkSize : (NSString*)chunkSize
                              offset : (NSString*)offset
                               chunk : (NSData*)chunk
                       sessionCookie : (NSString*)sessionCookie
                              success:(void (^)(NSString *user))success
                              failure:(void(^)(NSError *error))failure;

@end
