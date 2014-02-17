//
//  ViblioHelper.m
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "ViblioHelper.h"
#import <FBUtility.h>

@implementation ViblioHelper

NSString *const refreshProgress = @"com.viblio.app : UplodProgressNotification";
NSString *const uploadComplete = @"com.viblio.app : uploadComplete";
NSString * const uploadVideoPaused = @"com.viblio.app : uploadVideoPaused";
NSString *const playVideo = @"com.viblio.app : playVideo";
NSString * const stopVideo = @"com.viblio.app : stopVideo";

+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters
{
    return [FBUtility stringBySerializingQueryParameters:queryParameters];
}

+(void)displayAlertWithTitle:(NSString*)titleString
                 messageBody:(NSString*)body
              viewController:(UIViewController*)controller
              cancelBtnTitle:(NSString*)cancelBtnTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
                                                    message:body
                                                   delegate:controller
                                          cancelButtonTitle:cancelBtnTitle
                                          otherButtonTitles:nil];
    [alert show];
    alert = nil;
}

NSString* Viblio_wideNonWideSegue(NSString *segueName)
{
    NSString *segueName_ = segueName;
    if(IS_IPHONE_5)
        segueName_ = [segueName_ stringByAppendingFormat:@"Wide"];
    DLog(@"Log : Returning value - %@", segueName_);
    return segueName_;
}

+(void)clearSessionVariables
{
    // Assets will be loaded on subsequent logins again
    
    [VCLIENT.filteredVideoList  removeAllObjects];
    VCLIENT.filteredVideoList = nil;
    

    [DBCLIENT deleteUserEntity];
    APPMANAGER.user = nil;
    UserClient.emailId = nil; UserClient.password = nil; UserClient.sessionCookie = nil;
    UserClient.isNewUser = @(NO); UserClient.isFbUser = @(NO); UserClient.userID = nil;
    UserClient.fbAccessToken = nil;
}

// The font list to be used

/*      "Aleo-Regular",
        "Aleo-Bold",
        "Aleo-Italic",
        "Aleo-LightItalic",
        "Aleo-Light",
        "Aleo-BoldItalic"     */


+(UIFont*)viblio_Font_Bold_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo-Bold" size:fontSize];
    if(isBold)
        customFont = [UIFont boldSystemFontOfSize:fontSize];
    return customFont;
}

+(UIFont*)viblio_Font_Bold_Italic_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo-BoldItalic" size:fontSize];
    if(isBold)
        customFont = [UIFont boldSystemFontOfSize:fontSize];
    return customFont;
}

+(UIFont*)viblio_Font_Italic_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo-Italic" size:fontSize];
    if(isBold)
        customFont = [UIFont boldSystemFontOfSize:fontSize];
    return customFont;
}

+(UIFont*)viblio_Font_Light_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo-Light" size:fontSize];
    if(isBold)
        customFont = [UIFont boldSystemFontOfSize:fontSize];
    return customFont;
}

+(UIFont*)viblio_Font_Light_Italic_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo-LightItalic" size:fontSize];
    if(isBold)
        customFont = [UIFont boldSystemFontOfSize:fontSize];
    return customFont;
}

+(UIFont*)viblio_Font_Regular_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo-Regular" size:fontSize];
    if(isBold)
        customFont = [UIFont boldSystemFontOfSize:fontSize];
    return customFont;
}

+(BOOL)vbl_isValidEmail:(NSString *)emailString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

+(NSError*)getCustomErrorWithMessage:(NSString*)errMsg withCode:(NSUInteger)code
{
    DLog(@"Log : The error message to be shown in the custom object is - %@", errMsg);
    NSMutableDictionary *details = [[NSDictionary dictionary] mutableCopy];
    [details setValue:errMsg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:ERROR_DOMAIN code:code userInfo:details];
    
}

+(NSUInteger) DeviceSystemMajorVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{_deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];});
    return _deviceSystemMajorVersion;
}


+(UIView *)vbl_navigationTitleView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 17)];
    [imageView setImage:[UIImage imageNamed:@"viblio"]];
    return (UIView *)imageView;
}

+(UIView *)vbl_navigationTellAFriendTitleView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 17)];
    [imageView setImage:[UIImage imageNamed:@"tell_friend"]];
    return (UIView *)imageView;
}

+(UIView *)vbl_navigationFeedbackTitleView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 17)];
    [imageView setImage:[UIImage imageNamed:@"feedback"]];
    return (UIView *)imageView;
}


+(UIImage*)setUpNavigationBarBackgroundImage
{
    UIImage *gradientImage44;
    if([ViblioHelper DeviceSystemMajorVersion] < 7)
        gradientImage44 = [[UIImage imageNamed:@"nav_bar_ios6"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    else
        gradientImage44 = [[UIImage imageNamed:@"nav_bar_ios7"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    return gradientImage44;
}


+(void)setUpNavigationBarForController : (UIViewController*)vc withLeftBarButtonSelector : (SEL)leftSelector andRightBarButtonSelector : (SEL) rightSelector
{
    [vc.navigationItem setTitleView:[ViblioHelper vbl_navigationTitleView]];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                           [UIButton navigationItemWithTarget:vc action:leftSelector withImage:@"" withTitle:@"Cancel"]];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                            [UIButton navigationItemWithTarget:vc action:rightSelector withImage:@"" withTitle:@"Done"]];
}

+(UIColor*)getVblRedColor
{
    return [UIColor colorWithRed:0.8196 green:0.3372 blue:0.2075 alpha:1];
}

+(UIColor*)getVblGrayColor
{
    return [UIColor colorWithRed:0.3725 green:0.3843 blue:0.4431 alpha:1];
}

+(UIColor*)getVblBlueColor
{
    return [UIColor colorWithRed:0.2117 green:0.2196 blue:0.2784 alpha:1];
}


+ (void)downloadImageWithURLString:(NSString *)urlString completion:(void (^)(UIImage *image, NSError *error))completion
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager downloadWithURL:[NSURL URLWithString:urlString]
                     options:SDWebImageCacheMemoryOnly
                    progress:nil
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                       
                       completion(image, error);
                   }];
}

+(NSArray*)getDateTimeStampToReadableFormat : (NSString*)dateStamp
{
    DLog(@"Log : dateStamp received is - %@", dateStamp);
    NSArray *dateTimeSep = [dateStamp componentsSeparatedByString:@" "];
    NSArray *dateComps = [dateTimeSep[0] componentsSeparatedByString:@"-"];
    //NSArray *timeComps = [dateTimeSep[1] componentsSeparatedByString:@":"];
    NSString *displayString = [self getMonthInWords:dateComps[1]];
    //dateTimeSep = nil;
    displayString = [displayString stringByAppendingString:@" "];
    displayString = [displayString stringByAppendingString:dateComps[2]];
    displayString = [displayString stringByAppendingString:@", "];
    displayString  = [displayString stringByAppendingString:dateComps[0]];
    
    //NSString *time = [time string];
    DLog(@"Log : String being sent back is - %@", displayString);
    return @[displayString, dateTimeSep[1]];
}

+(NSString*)getMonthInWords : (NSString*)month
{
    DLog(@"Log : The value received is - %@", month);
    NSDictionary *months = @{ @"01" : @"Jan",
                              @"02" : @"Feb",
                              @"03" : @"Mar",
                              @"04" : @"April",
                              @"05" : @"May",
                              @"06" : @"June",
                              @"07" : @"July",
                              @"08" : @"Aug",
                              @"09" : @"Sep",
                              @"10" : @"Oct",
                              @"11" : @"Nov",
                              @"12" : @"Dec"};
    
    DLog(@"Log : Value being returned is - %@", [months valueForKey:month]);
    return [months valueForKey:month];
}

@end
