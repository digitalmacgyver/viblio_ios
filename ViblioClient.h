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
#define ERROR_DOMAIN @"com.viblio.error"

@interface ViblioClient : AFHTTPClient <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property(nonatomic, assign) double uploadedSize;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionUploadTask *uploadTask;
@property (nonatomic) NSString *filePath;

+ (ViblioClient *)sharedClient;

- (void)authenticateUserWithEmail : (NSString*)emailID
                         password : (NSString*)password
                             type : (NSString*)loginType
                           success:(void (^)(NSString *msg))success
                           failure:(void(^)(NSError *error))failure;


- (void)authenticateUserWithFacebook : (NSString*)accessToken
                                type : (NSString*)loginType
                              success:(void (^)(NSString *msg))success
                              failure:(void(^)(NSError *error))failure;


- (void)createNewUserAccountWithEmail : (NSString *)emailID
                             password : (NSString*)password
                          displayName : (NSString*)displayName
                                 type : (NSString*)loginType
                               success:(void (^)(NSString *msg))success
                               failure:(void(^)(NSError *error))failure;


- (void)createNewUserAccountWithFB : (NSString *)accessToken
                              type : (NSString*)loginType
                            success:(void (^)(NSString *user))success
                            failure:(void(^)(NSError *error))failure;


- (void)getUserSessionDetails : (void (^)(NSString *user))success
                      failure : (void(^)(NSError *error))failure;


-(void)startUploadingFileForUserId : (NSString*)userUUId
                     fileLocalPath : (NSString*)fileLocalPath
                          fileSize : (NSString*)fileSize
                           success : (void (^)(NSString *fileLocation))success
                           failure : (void(^)(NSError *error))failure;


-(void)getOffsetOfTheFileAtLocationID : (NSString*)fileLocationID
                        sessionCookie : (NSString*)sessionCookie
                              success : (void (^)(double offset))success
                              failure : (void(^)(NSError *error))failure;


- (void)resumeUploadOfFileLocationID : (NSString*)fileLocationID
                       localFileName : (NSString*)fileName
                           chunkSize : (NSString*)chunkSize
                              offset : (NSString*)offset
                               chunk : (NSData*)chunk
                       sessionCookie : (NSString*)sessionCookie
                              success:(void (^)(NSString *user))successCallback
                              failure:(void(^)(NSError *error))failureCallback;


-(void)invalidateFileUploadTask;

-(void)getCountOfMediaFilesUploadedByUser:(void(^)(int count))success
                                 failure : (void (^) (NSError *error))failure;

-(void)passwordForgot : (NSString*)emailId
              success : (void(^)(NSString *msg))success
              failure : (void(^)(NSError *error))failure;

-(void)fetchTermsAndConditions:(void(^)(NSString *terms))success
                       failure:(void(^)(NSError *error))failure;

-(void)invalidateUploadTaskWithoutPausing;

-(void)sendFeedbackToServerWithText:(NSString*)text
                          category : (NSString*)categorySelected
                            success:(void(^)(NSString *msg))success
                            failure:(void(^)(NSError *error))failure;

-(void)getTheListOfMediaFilesOwnedByUserWithOptions : (NSString*)vwStyle
                                          pageCount : (NSString*)page
                                               rows : (NSString*)rowsInAPage
                                             success:(void(^)(NSMutableArray *result))success
                                             failure:(void(^)(NSError *error))failure;

-(void)getTheCloudUrlForVideoStreamingForFileWithUUID : (NSString*)uuid
                                               success:(void(^)(NSString *cloudURL))success
                                               failure:(void(^)(NSError *error))failure;


-(void)getListOfSharedWithMeVideos :(void(^)(NSArray *sharedList))success
                            failure:(void(^)(NSError *error))failure;

-(void)streamAvatarsImageForUUID : (NSString*)uuid
                          success:(void(^)(UIImage *profileImage))success
                          failure:(void(^)(NSError *error))failure;


-(void)getFacesInAMediaFileWithUUID : (NSString*)uuid
                             success:(void(^)(NSArray *faceList))success
                             failure:(void(^)(NSError *error))failure;

-(void)getAddressWithLat : (NSString*)latitude andLong : (NSString*)longitude
                  success:(void(^)(NSString *formattedAddress))success
                  failure:(void(^)(NSError *error))failure;

-(void)hasAMediaFileBeenSharedByTheUSerWithUUID : (NSString*)uuid
                                         success:(void(^)(BOOL hasBeenShared))success
                                         failure:(void(^)(NSError *error))failure;

-(AFJSONRequestOperation*)sharingToUsersWithSubject : (NSString*)subject
                            body : (NSString*)body
                          fileId : (NSString*)mid
                         success : (void(^)(BOOL hasBeenShared))success
                          failure:(void(^)(NSError *error))failure;
@end
