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
    return segueName_;
}

-(void)clearSessionVariables
{
    // Assets will be loaded on subsequent logins again
    
    [VCLIENT.filteredVideoList  removeAllObjects];
    VCLIENT.filteredVideoList = nil;
}


+(UIFont*)viblio_Font_Bold_WithSize:(CGFloat)fontSize isBold : (BOOL)isBold
{
    UIFont *customFont = [UIFont fontWithName:@"Aleo Light" size:fontSize];
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
    UIFont *customFont = [UIFont fontWithName:@"Aleo Light Italic" size:fontSize];
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

@end
