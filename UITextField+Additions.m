//
//  UITextField+Additions.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/15/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "UITextField+Additions.h"

@implementation UITextField (ViblioAdditions)

-(BOOL)isTextValid
{
    if( self != nil && self.text != nil && self.text.length > 0)
        return YES;
    return NO;
}

@end
