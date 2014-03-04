//
//  UIButton+Additions.h
//  Viblio_v2
//
//  Created by Dunty Vinay Raj B Mon 12/06/13.
//  Copyright (c) 2013 CognitiveClouds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

+ (UIButton*)navigationItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image;
+ (UIView*)navigationRightItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image withTitle:(NSString *)title;
+ (UIView*)navigationLeftItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image withTitle:(NSString *)title;

@end
