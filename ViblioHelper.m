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
NSString * const showingSharingView = @"com.viblio.app : showSharingView";
NSString * const removeSharingView = @"com.viblio.app : removeSharingView";
NSString * const showListSharingVw = @"com.viblio.app : showListSharingView";
NSString * const removeListSharinVw = @"com.viblio.app : removeListSharingView";
NSString * const showContactsScreen = @"com.viblio.app : showContactsScreen";
NSString * const removeContactsScreen = @"com.viblio.app : removeContactsScreen";

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

// Function to find differece between two dates

+ (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return (int)([components day]);
}

+(NSDictionary*)getDateTimeCategorizedArrayFrom : (NSArray*)videoList
{
    NSDate *curDate = [NSDate date];
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    [result setValue:@[@"Today"] forKey:@"SectionA"];
    [result setValue:@[@"This Week"] forKey:@"SectionB"];
    [result setValue:@[@"This Month"] forKey:@"SectionC"];
    [result setValue:@[@"This Year"] forKey:@"SectionD"];
    [result setValue:@[@"Older"] forKey:@"SectionE"];
    
    for( int i=0; i < videoList.count; i++ )
    {
        DLog(@"Log : Result dictionary is - %@", result);
        
        id video = videoList[i];
        NSDate *videoDate;
        NSString *dateStr;

        // 2014-02-07 14:21:00
        // 2014-01-30 18:20:34
        
        DLog(@"Log : The class of object is - %@", NSStringFromClass([video class]));
        if( [video isKindOfClass:[cloudVideos class]] )
            dateStr = ((cloudVideos*)video).createdDate;
        else
            dateStr = ((SharedVideos*)video).sharedDate;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        videoDate = [dateFormat dateFromString:dateStr];
        dateFormat = nil;
        dateStr = nil;
        
        NSDateComponents *videoDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:videoDate];
        
        NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |NSCalendarUnitMonth | NSCalendarUnitYear fromDate:curDate];
        
        DLog(@"Log : Video week - %d, current week - %d", videoDateComponents.weekOfMonth, currentDateComponents.weekOfMonth);
        
        if( videoDateComponents.year == currentDateComponents.year )
        {
            if( videoDateComponents.month == currentDateComponents.month )
            {
                if( videoDateComponents.weekOfMonth == currentDateComponents.weekOfMonth )
                {
                    if( videoDateComponents.day == currentDateComponents.day )
                        result = [self addObjectToArray:@"SectionA" :video toRsult:result];
                    else
                        result = [self addObjectToArray:@"SectionB" :video toRsult:result];
                }
                else
                    result = [self addObjectToArray:@"SectionC" :video toRsult:result];
            }
            else
                result = [self addObjectToArray:@"SectionD" :video toRsult:result];
        }
        else
            result = [self addObjectToArray:@"SectionE" :video toRsult:result];
        
//        if( videoDateComponents.day == currentDateComponents.day )
//            result = [self addObjectToArray:@"Today" :video toRsult:result];
//        else if (videoDateComponents.weekOfMonth == currentDateComponents.weekOfMonth)
//            result = [self addObjectToArray:@"This Week" :video toRsult:result];
//        else if (videoDateComponents.month == currentDateComponents.month)
//            result = [self addObjectToArray:@"This Month" :video toRsult:result];
//        else if (videoDateComponents.year == currentDateComponents.year)
//            result = [self addObjectToArray:@"This Year" :video toRsult:result];
//        else
        
        
        videoDateComponents = nil;
        currentDateComponents = nil;
        
        videoDate = nil;
        video = nil;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    for ( NSString *category in result )
    {
        if( ((NSArray*)result[category]).count <= 1 )
           [array addObject:category]; //[result removeObjectForKey:category];
    }
    
    DLog(@"Log : The result before for loop is - %@", result);
    for( int i=0; i<array.count; i++ )
    {
        [result removeObjectForKey:array[i]];
    }
    
    DLog(@"Log : The result is - %@", result);
    
    return result;
}

+(NSMutableDictionary*)addObjectToArray : (NSString*)key :(id)obj toRsult : (NSMutableDictionary*)result
{
    NSMutableArray *arr = [[result valueForKey:key] mutableCopy];
    DLog(@"Log : The object to be added is - %@", obj);
    [arr addObject:obj];
    [result setValue:arr forKey:key];
//    [arr removeAllObjects];
//    arr = nil;
    return result;
}

@end
