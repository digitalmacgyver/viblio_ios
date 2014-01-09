//
//  ViblioHelper.h
//  Viblio_v1
//
//  Created by Dunty Vinay Raj on 1/2/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViblioHelper : NSObject

+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters;
+(void)displayAlertWithTitle:(NSString*)titleString
                 messageBody:(NSString*)body
              viewController:(UIViewController*)controller
              cancelBtnTitle:(NSString*)cancelBtnTitle;

@end
