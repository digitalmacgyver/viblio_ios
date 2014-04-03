//
//  ViblioGlobals.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/6/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#ifndef Viblio_v2_ViblioGlobals_h
#define Viblio_v2_ViblioGlobals_h

// Comment the below line to get non-verbose logs

#define VERBOSE_LOGS

#ifdef DEBUG
#ifdef VERBOSE_LOGS
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define DLog(...) NSLog(__VA_ARGS__)
#endif
#else
#	define DLog(...)
#endif


// Server URL
#ifdef DEBUG
#define API_UPLOAD_FILE_SERVER_URL @"https://staging.viblio.com/files"
#define API_LOGIN_SERVER_URL @"https://staging.viblio.com"
#else
#define API_UPLOAD_FILE_SERVER_URL @"https://viblio.com/files"
#define API_LOGIN_SERVER_URL @"https://staging.viblio.com"
#endif



// Frameworks
#import <AFNetworking/AFNetworking.h>
#import <FacebookSDK/FacebookSDK.h>

//
// Macros for hardware detection
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#define AppDlegate (AppDelegate*)[[UIApplication sharedApplication]delegate]
#define KeyBoardShiftSize 200

#import "AppDelegate.h"
#import "AuthControllers.h"

//Services
#import "ViblioClient.h"

//Utilities
#import "ViblioHelper.h"
#import "CoreDataManager.h"
#import "VideoManager.h"
#import "AppManager.h"
#import "UserManager.h"
#import "VblLocationManager.h"

//Modals
#import "User.h"
#import "Info.h"
#import "Videos.h"
#import "Session.h"
#import "cloudVideos.h"
#import "SharedVideos.h"

//Addtions
#import "UITextField+Additions.h"

#endif
