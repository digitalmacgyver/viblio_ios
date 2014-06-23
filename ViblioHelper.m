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
NSString * const showingSharingView = @"com.viblio.app : showingSharingView";
NSString * const removeSharingView = @"com.viblio.app : removeSharingView";
NSString * const showListSharingVw = @"com.viblio.app : showListSharingView";
NSString * const removeListSharinVw = @"com.viblio.app : removeListSharingView";
NSString * const showContactsScreen = @"com.viblio.app : showContactsScreen";
NSString * const removeContactsScreen = @"com.viblio.app : removeContactsScreen";
NSString * const logoutUser = @"com.viblio.app : logoutUser";
NSString * const reloadListView = @"com.viblio.app : reloadListView";
NSString * const showSharingView = @"com.viblio.app : showSharingView";
NSString * const removeOwnerSharingView = @"com.viblio.app : removeOwnerSharingView";
NSString * const newVideoAvailable = @"com.viblio.app : newVideoAvailable";
NSString * const wifiSignalLost = @"com.viblio.app : wifiSignalLost";
NSString * const moviePlayerEnded = @"com.viblio.app : moviePlayerEnded";

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

    VCLIENT.resCategorized = nil;
    
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
    if( month.length < 2 )
        month = [@"0" stringByAppendingString:month];
    
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

+(int)getDigitizedMonth : (NSString*)month
{
    DLog(@"Log : The value received is - %@", month);
    
    NSDictionary *months = @{ @"Jan" : @"01" ,
                              @"Feb" : @"02" ,
                              @"Mar" : @"03" ,
                              @"April" : @"04",
                              @"May" : @"05",
                              @"June" : @"06",
                              @"July" : @"07",
                              @"Aug" : @"08",
                              @"Sep" : @"09",
                              @"Oct" : @"10",
                              @"Nov" : @"11",
                              @"Dec" : @"12" };
    
    DLog(@"Log : Value being returned is - %@", [months valueForKey:month]);
    return ((NSString*)[months valueForKey:month]).intValue;
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
    
 //   DLog(@"Log : The videolist is - %@", videoList);
    
    
    //return  nil;
    
    
    NSDate *curDate = [NSDate date];
    NSMutableDictionary *result = [NSMutableDictionary new];

    [result setValue:@[] forKey:@"Today"];
    [result setValue:@[] forKey:@"This Week"];
    [result setValue:@[] forKey:@"This Month"];
    
  //  DLog(@"Log : The video list count is - %d", videoList.count);
    
    for( int i=0; i < videoList.count; i++ )
    {
     //   DLog(@"Log : Result dictionary is - %@", result);
        
        id video = videoList[i];
        NSDate *videoDate;
        NSString *dateStr;

        // 2014-02-07 14:21:00
        // 2014-01-30 18:20:34
        
     //   DLog(@"Log : The class of object is - %@", NSStringFromClass([video class]));
        
        if( APPMANAGER.indexOfSharedListSelected != nil )
        {
            dateStr = ((NSDictionary*)videoList[i])[@"shared_date"];
        }
        else
        {
            if( [video isKindOfClass:[cloudVideos class]] )
                dateStr = ((cloudVideos*)video).createdDate;
            else
                dateStr = ((NSDictionary*)[video[@"media"] firstObject])[@"shared_date"];
        }

        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        videoDate = [dateFormat dateFromString:dateStr];
        dateFormat = nil;
        dateStr = nil;
        
        NSDateComponents *videoDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:videoDate];
        
        NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |NSCalendarUnitMonth | NSCalendarUnitYear fromDate:curDate];
        
    //    DLog(@"Log : Video week - %d, current week - %d", videoDateComponents.weekOfMonth, currentDateComponents.weekOfMonth);
        
        if( videoDateComponents.year == currentDateComponents.year )
        {
            if( videoDateComponents.month == currentDateComponents.month )
            {
                if( videoDateComponents.weekOfMonth == currentDateComponents.weekOfMonth )
                {
                    if( videoDateComponents.day == currentDateComponents.day )
                        result = [self addObjectToArray:@"Today" :video toRsult:result];
                    else
                        result = [self addObjectToArray:@"This Week" :video toRsult:result];
                }
                else
                    result = [self addObjectToArray:@"This Month" :video toRsult:result];
                
            }
            else
            {
     //           DLog(@"Log : video belongs to older month.. Create a section for that month...");
                
                // Check whether the section with that month already exists
                
                NSString *month = [self getMonthInWords:[NSString stringWithFormat:@"%d",videoDateComponents.month]];
                NSString *year = [NSString stringWithFormat:@"%d", videoDateComponents.year];
                NSString *sectionHeader = [[month stringByAppendingString:@", "] stringByAppendingString:year];
                
                DLog(@"Log : section header is - %@", sectionHeader);
                if( result[ sectionHeader ] == nil )
                {
                    DLog(@"Log : A key for the month does not exist...");
                    [result setValue:@[] forKey:sectionHeader];
                }
                
                result = [self addObjectToArray:sectionHeader :video toRsult:result];
            }
        }
        else
        {
   //         DLog(@"Log : Video belongs to some older year... Create a header of that year");
   
            // Check whether the section with that year already exists
            
            if( result[[NSString stringWithFormat:@"%d",videoDateComponents.year]] == nil )
            {
                DLog(@"Log : A key for the year does not exist...");
                [result setValue:@[] forKey:[NSString stringWithFormat:@"%d",videoDateComponents.year]];
            }
                
            result = [self addObjectToArray:[NSString stringWithFormat:@"%d",videoDateComponents.year] :video toRsult:result];
        }
        
        videoDateComponents = nil;
        currentDateComponents = nil;
        
        videoDate = nil;
        video = nil;
    }
//
    NSMutableArray *array = [NSMutableArray new];
    for ( NSString *category in result )
    {
        if( ((NSArray*)result[category]).count <= 0 )
           [array addObject:category]; 
    }
    
  //  DLog(@"Log : The result before for loop is - %@", result);
    for( int i=0; i<array.count; i++ )
    {
        [result removeObjectForKey:array[i]];
    }
    
   // DLog(@"Log : The result is - %@", result);
    
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
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreate( );
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
      //  DLog(@" Log : Mail Clicked - 3");
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        DLog(@"Log : *************************** CHECKPOINT - 1*****************************");
        
        if( APPMANAGER.contacts != nil )
        {
            [APPMANAGER.contacts removeAllObjects];
            APPMANAGER.contacts = nil;
        }
        
        
        DLog(@"Log : *************************** CHECKPOINT - 1.1 *****************************");
        APPMANAGER.contacts = [NSMutableArray new];
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSMutableArray *emailIds = [NSMutableArray new];

            for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(email, i);
                [emailIds addObject:phoneNumber];
            }
            
            if( emailIds.count > 0 )
            {
                if( [firstName isValid] || [lastName isValid] )
                {
                    if( ![firstName isValid] )
                    {
                        firstName = @"";
                        
                        if( [lastName isValid] )
                        {
                            firstName = lastName;
                            lastName = @"";
                        }
                    }
                    if( ![lastName isValid] )
                    {
                        lastName = @"";
                    }
                    
                    int index = -1;
                    
                    DLog(@"Log : *************************** CHECKPOINT - 1.2 *****************************");
                    
                    index = [self getIndexOfContactIfExistsWithFname:firstName andLname:lastName];
                    
                    DLog(@"Log : *************************** CHECKPOINT - 1.3 *****************************");
                   // DLog(@"Log : The index at which the object is found is - %d", index);
                    
                    if( index == -1 )
                    {
                        [APPMANAGER.contacts addObject:@{ @"fname" : firstName, @"lname" : lastName, @"email" : emailIds}];
                    }
                    else
                    {
                        NSMutableDictionary *contact = [APPMANAGER.contacts[index] mutableCopy];
                        NSMutableArray *ContactemailIds = contact[@"email"];
                        
                        //emailIds = [[emailIds arrayByAddingObjectsFromArray:emailIds] mutableCopy];
                        
                        for (int i=0; i<emailIds.count; i++) {
                            
                            if( ![self isEmailIdExisting:ContactemailIds andEmail:emailIds[i]] )
                            {
                                [ContactemailIds addObject:emailIds[i]];
                            }
                         
                        }
                        
                        [contact setValue:ContactemailIds forKey:@"email"];
                        
                        [APPMANAGER.contacts removeObjectAtIndex:index];
                        [APPMANAGER.contacts insertObject:contact atIndex:index];
                    }
                
                }
                else
                    [APPMANAGER.contacts addObject:@{ @"email" : emailIds}];
            }
        }
        
        DLog(@"Log : *************************** CHECKPOINT - 1.4 *****************************");
        DLog(@"Log : The contacts are - %@", APPMANAGER.contacts);
        APPMANAGER.contacts = [[self getSortedArrayFromArray:APPMANAGER.contacts] mutableCopy];
    }
    else {

        [ViblioHelper displayAlertWithTitle:@"Error" messageBody:@"Viblio could not access your contacts. Please enable access in settings" viewController:nil cancelBtnTitle:@"OK"];
    }
}

+(BOOL)isEmailIdExisting : (NSMutableArray*)contatcts andEmail : (NSString*)emailId
{
    if( contatcts != nil && contatcts.count > 0 )
    {
        for( int i=0; i<contatcts.count; i++ )
        {
            if( [emailId isEqualToString:contatcts[i]] )
            {
                return YES;
            }
        }
    }

    return NO;
}


+(int)getIndexOfContactIfExistsWithFname : (NSString*)fname andLname : (NSString*)lname
{
    if( APPMANAGER.contacts != nil && APPMANAGER.contacts.count > 0 )
    {
        for( int i=0; i < APPMANAGER.contacts.count; i++ )
        {
            NSDictionary *contact = APPMANAGER.contacts[i];
            
            if( [fname isEqualToString:contact[@"fname"]] && [lname isEqualToString:contact[@"lname"]] )
            {
                return i;
            }
        }
    }
    
    return -1;
}


+(NSMutableArray*)getSortedArrayFromArray : (NSMutableArray*)contacts
{
    DLog(@"Log : *************************** CHECKPOINT - 1.5 *****************************");
    
    if( contacts != nil && contacts.count > 0 )
    {
        NSMutableArray *emailArray = [[NSMutableArray alloc]init];
        NSMutableArray *nameArray = [[NSMutableArray alloc]init];
        
        for( int i=0; i<contacts.count; i++ )
        {
            NSDictionary *obj = contacts[i];
            if( obj[@"fname"] != nil && ( ((NSString*)obj[@"fname"]).length > 0 ) )
            {
                [nameArray addObject:contacts[i]];
            }
            else
                [emailArray addObject:contacts[i]];
        }
        
        if( nameArray != nil && nameArray.count > 0 )
        {
            nameArray = [self getSortedList : nameArray  usingKey : @"fname"];
        }
        
        if ( emailArray != nil && emailArray.count > 0 )
        {
            emailArray = [self getSortedEmailList:emailArray usingKey:@"email"];
            
            int j = 0;
            for ( int i =0 ; i < nameArray.count; i++ )
            {
                //  DLog(@"Log : The j value is - %d", j);
                
                NSString *email = [((NSMutableArray*)((NSDictionary*)emailArray[j])[@"email"]) firstObject];
                NSString *name = ((NSDictionary*)nameArray[i])[@"fname"];
                
                DLog(@"Log : Name and email are - %@ ---- %@", name, email);
                NSComparisonResult result;
                result = [[name lowercaseString] compare:[email lowercaseString]];
                
                DLog(@"Log : The comparison result is - %d", result);
                if( result == NSOrderedDescending )
                {
                    DLog(@"Log : Yes ordered in descending now....");
                    [nameArray insertObject:emailArray[j] atIndex:i];
                    j++;
                    
                    if( j >= emailArray.count )
                    {
                        break;
                    }
                }
            }
            
            if( j < emailArray.count )
            {
                for( int i=j ; i < emailArray.count; i++ )
                {
                    [nameArray addObject:emailArray[i]];
                }
            }
        }
    
        DLog(@"Log : The name array being returned is - %@", nameArray);
        return [nameArray mutableCopy];
    }
    
    return nil;
}

+(NSMutableArray*)getSortedList : (NSArray*)contacts usingKey : (NSString*)key
{
    DLog(@"Log : *************************** CHECKPOINT - 1.6 *****************************");
    NSArray *sortedList;
    sortedList = [contacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        return [[((NSDictionary*)a)[key] lowercaseString] compare:[((NSDictionary*)b)[key] lowercaseString]];
    }];
    DLog(@"Log : The sorted name list - %@", sortedList);
    return [sortedList mutableCopy];
}

+(NSMutableArray*)getSortedEmailList : (NSArray*)contacts usingKey : (NSString*)key
{
    NSArray *sortedList;
    sortedList = [contacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        return [ [((NSArray*) (((NSDictionary*)a)[key])) firstObject] compare:[((NSArray*) (((NSDictionary*)b)[key])) firstObject]];
    }];
    DLog(@"Log : The sorted name list - %@", sortedList);
    return [sortedList mutableCopy];
}


+(NSArray*)getReOrderedListOfKeys :(NSArray*)keys
{
   // DLog(@"Log : The keys obtained are - %@", keys);
    NSMutableArray *priorityFirst = [[NSMutableArray alloc]init];
    NSMutableArray *prioritySecond = [[NSMutableArray alloc]init];
    NSMutableArray *priorityThird = [[NSMutableArray alloc]init];
    
    NSMutableArray *sortedList = [[NSMutableArray alloc] init];
    
    NSCharacterSet* digits = [NSCharacterSet decimalDigitCharacterSet];
    
    for( NSString *str in keys )
    {
    //    DLog(@"Log : Str obtained is - %@", str);
        
        if( [str isEqualToString:@"Today"] || [str isEqualToString:@"This Week"] || [str isEqualToString:@"This Month"] )
        {
            [priorityFirst addObject:str];
        }
        else
        {
            if( [digits characterIsMember: [str characterAtIndex:0]]  )
                [priorityThird addObject:str];
            else
                [prioritySecond addObject:str];
        }
    }
    
    sortedList = [[sortedList arrayByAddingObjectsFromArray:[[priorityFirst reverseObjectEnumerator] allObjects]] mutableCopy];
    priorityFirst = nil;
    
    sortedList = [[sortedList arrayByAddingObjectsFromArray: [self getOrderedListForMonth:prioritySecond]] mutableCopy];
    prioritySecond = nil;
    
    sortedList = [[sortedList arrayByAddingObjectsFromArray:[[priorityThird reverseObjectEnumerator] allObjects]] mutableCopy];
    priorityThird = nil;
    
    return sortedList;
}

+(NSArray*)getOrderedListForMonth : (NSMutableArray*)monthArray
{
  //  DLog(@"Log : The month array is - %@", monthArray);
    
    NSMutableArray *sortedRes = [NSMutableArray new];
    for(int i =0 ; i < monthArray.count; i++ )
    {
        NSString *str = [[monthArray[i] componentsSeparatedByString:@", "] firstObject];
        if( i > 0 )
        {
            BOOL isInserted = NO;
            for( int i=0; i < sortedRes.count; i++ )
            {
                if( [self getDigitizedMonth:[[monthArray[i] componentsSeparatedByString:@", "] firstObject]] < [self getDigitizedMonth:str] )
                {
                    [sortedRes insertObject:monthArray[i] atIndex:i];
                    isInserted = YES;
                    break;
                }
            }
            
            if(!isInserted)
                [sortedRes addObject:monthArray[i]];
        }
        else
            [sortedRes addObject:monthArray[i]];
    }
    
   // DLog(@"Log : The sorted res - %@", sortedRes);
    return sortedRes;
}


@end
