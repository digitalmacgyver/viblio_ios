//
//  ViblioHelper.h
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButton+Additions.h"
#import "SDWebImageManager.h"
#import <AddressBook/AddressBook.h>

@interface ViblioHelper : NSObject

extern NSString * const refreshProgress;
extern NSString * const uploadComplete;
extern NSString * const uploadVideoPaused;
extern NSString * const playVideo;
extern NSString * const stopVideo;
extern NSString * const showingSharingView;
extern NSString * const removeSharingView;

extern NSString * const showListSharingVw;
extern NSString * const removeListSharinVw;

extern NSString * const showContactsScreen;
extern NSString * const removeContactsScreen;
extern NSString * const logoutUser;
extern NSString * const reloadListView;

+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters;

+(void)displayAlertWithTitle:(NSString*)titleString
                 messageBody:(NSString*)body
              viewController:(UIViewController*)controller
              cancelBtnTitle:(NSString*)cancelBtnTitle;

NSString* Viblio_wideNonWideSegue(NSString *segueName);

+(UIFont*)viblio_Font_Bold_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold;
+(UIFont*)viblio_Font_Bold_Italic_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold;
+(UIFont*)viblio_Font_Italic_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold;
+(UIFont*)viblio_Font_Light_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold;
+(UIFont*)viblio_Font_Light_Italic_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold;
+(UIFont*)viblio_Font_Regular_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold;

+(BOOL)vbl_isValidEmail:(NSString *)emailString;

+(NSError*)getCustomErrorWithMessage:(NSString*)errMsg withCode:(NSUInteger)code;
+(NSUInteger) DeviceSystemMajorVersion;
+(UIImage*)setUpNavigationBarBackgroundImage;


+(UIView *)vbl_navigationTitleView;
+(UIView *)vbl_navigationFeedbackTitleView;
+(UIView *)vbl_navigationTellAFriendTitleView;
+(UIView *)vbl_navigationSetingsView;
+(UIView *)vbl_navigationInProgressView;
+(UIView *)vbl_navigationShareTitleView : (NSString*)title;

+(void)clearSessionVariables;
+(void)setUpNavigationBarForController : (UIViewController*)vc withLeftBarButtonSelector : (SEL)leftSelector andRightBarButtonSelector : (SEL) rightSelector;

+(UIColor*)getVblRedColor;
+(UIColor*)getVblGrayColor;
+(UIColor*)getVblBlueColor;
+(UIColor*)getVblGreenishBlueColor;

+ (void)downloadImageWithURLString:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion;
+(NSArray*)getDateTimeStampToReadableFormat : (NSString*)dateStamp;
+ (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;
+(NSDictionary*)getDateTimeCategorizedArrayFrom : (NSArray*)videoList;

@end
