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

@end
