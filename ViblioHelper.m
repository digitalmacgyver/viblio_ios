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
NSString * const logoutUser = @"com.viblio.app : logoutUser";
NSString * const reloadListView = @"com.viblio.app : reloadListView";

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
    
    APPMANAGER.posterImageForVideoSharing = nil;
    APPMANAGER.videoToBeShared = nil;
    
    [VCLIENT.filteredVideoList  removeAllObjects];
    VCLIENT.filteredVideoList = nil;
    [VCLIENT.cloudVideoList removeAllObjects];
    VCLIENT.cloudVideoList = nil;

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
    UIView *vwTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 171, 27)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, -5, 111, 30)];
    [imageView setImage:[UIImage imageNamed:@"nav_logo"]];
    [vwTitle addSubview:imageView];
    return vwTitle;
}

+(UIView *)vbl_navigationShareTitleView : (NSString*)title
{
    UIView *vwTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 201, 20)];
    UILabel *lblTitle = [[ UILabel alloc ]initWithFrame:CGRectMake(0, 0, 201, 20)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = title; //@"Share with VIBLIO";
    lblTitle.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [vwTitle addSubview:lblTitle];
    //vwTitle.backgroundColor = [UIColor redColor];
    return vwTitle;
}

+(UIView *)vbl_navigationTellAFriendTitleView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 17)];
    [imageView setImage:[UIImage imageNamed:@"tell_friend"]];
    return (UIView *)imageView;
}

+(UIView *)vbl_navigationSetingsView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 22)];
    [imageView setImage:[UIImage imageNamed:@"settings"]];
    return (UIView *)imageView;
}

+(UIView *)vbl_navigationInProgressView
{
    UIView *vwTitle = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 171, 17)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 171, 17)];
    [imageView setImage:[UIImage imageNamed:@"text_uploads_in_progress"]];
    [vwTitle addSubview:imageView];
    return vwTitle;
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
                                           [UIButton navigationLeftItemWithTarget:vc action:leftSelector withImage:@"" withTitle:@"Cancel"]];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
                                            [UIButton navigationRightItemWithTarget:vc action:rightSelector withImage:@"" withTitle:@"Done" ]];
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

+(UIColor*)getVblGreenishBlueColor
{
    return [UIColor colorWithRed:.1098 green:.7215 blue:.8196 alpha:1];
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

+(void)MailSharingClicked : (id)sender
{
    DLog(@" Log : Mail Clicked - 2");
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreate( );
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        DLog(@" Log : Mail Clicked - 3");
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        if( APPMANAGER.contacts != nil )
        {
            [APPMANAGER.contacts removeAllObjects];
            APPMANAGER.contacts = nil;
        }
        
        DLog(@" Log : Mail Clicked - 4 - count - %ld", numberOfPeople);
        APPMANAGER.contacts = [NSMutableArray new];
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            DLog(@"Log : In processing contact - %d", i);
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSMutableArray *emailIds = [NSMutableArray new];
            
            DLog(@" Log : Mail Clicked 6 - %@", email);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(email, i);
                DLog(@" Log : Mail Clicked 7 - %@", phoneNumber);
                [emailIds addObject:phoneNumber];
            }
            
            if( emailIds.count > 0 )
            {
                DLog(@" Log : Mail Clicked 8 - %@ - %@ - %@", emailIds, firstName, lastName);
                
                if( [firstName isValid] && [lastName isValid] )
                    [APPMANAGER.contacts addObject:@{ @"fname" : firstName, @"lname" : lastName, @"email" : emailIds}];
                else
                    [APPMANAGER.contacts addObject:@{ @"email" : emailIds}];
                
            }
            
            // DLog(@" Log : Mail Clicked 9 - %@", APPMANAGER.contacts);
        }
        
        DLog(@" Log : Mail Clicked - 5");
//        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:Viblio_wideNonWideSegue(@"contacts")] animated:YES];
        //APPMANAGER.video = self.video;
        //[[NSNotificationCenter defaultCenter] postNotificationName:showContactsScreen object:nil];
    }
    else {
        // Send an alert telling user to change privacy setting in settings app
        
        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Viblio could not access your contacts. Please enable access in settings" viewController:nil cancelBtnTitle:@"OK"];
    }
}


@end
