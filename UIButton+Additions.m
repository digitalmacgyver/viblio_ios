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

+ (UIView*)navigationLeftItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image withTitle:(NSString *)title
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, 50, 50)];
    UIButton *_b = [UIButton buttonWithType:UIButtonTypeCustom];
    [_b.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];
    [_b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_b setTitle:title forState:UIControlStateNormal];
    [_b setTitle:title forState:UIControlStateHighlighted];
    [_b addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    _b.frame = containerView.frame;
    [containerView addSubview:_b];
    //_b.backgroundColor = [UIColor greenColor];
    containerView.backgroundColor = [UIColor clearColor];
    return containerView;
}

+ (UIView*)navigationRightItemWithTarget:(id)target action:(SEL)selector withImage:(NSString*)image withTitle:(NSString *)title
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, 70, 50)];
    UIButton *_b = [UIButton buttonWithType:UIButtonTypeCustom];
    [_b.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:16]];
    [_b setTitleColor:[ViblioHelper getVblGreenishBlueColor] forState:UIControlStateNormal];
    [_b setTitle:title forState:UIControlStateNormal];
    [_b setTitle:title forState:UIControlStateHighlighted];
    [_b addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    _b.frame = CGRectMake(25, 0, 70, 50); //containerView.frame;
    [containerView addSubview:_b];
    //_b.backgroundColor = [UIColor greenColor];
    containerView.backgroundColor = [UIColor clearColor];
    return containerView;
}
@end
