//
//  UIButton+Additions.h
//  Thrill
//
//  Created by Praveen Rachabattuni on 12/06/13.
//  Copyright (c) 2013 CognitiveClouds. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

+ (UIView*)navigationItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image
{
    UIButton *_b = [UIButton buttonWithType:UIButtonTypeCustom];
    [_b setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];

    [_b addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [_b imageForState:UIControlStateNormal].size;
    size.width = 40;//MAX(40, size.width);
    if( [ViblioHelper DeviceSystemMajorVersion] >= 7 )
        size.width = 25;
        [_b setFrame:(CGRect){CGPointZero,size}];
    
    return _b;
}

+ (UIView*)navigationItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image withTitle:(NSString *)title
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    UIButton *_b = [UIButton buttonWithType:UIButtonTypeCustom];
    [_b.titleLabel setFont:[ViblioHelper viblio_Font_Regular_WithSize:14 isBold:NO]];
    [_b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_b setTitle:title forState:UIControlStateNormal];
    [_b setTitle:title forState:UIControlStateHighlighted];
    [_b addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    _b.frame = containerView.frame;
    [containerView addSubview:_b];
    containerView.backgroundColor = [UIColor clearColor];
    return containerView;
}

@end
