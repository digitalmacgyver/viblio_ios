//
//  NSString+Additions.m
//  Viblio_v2
//
//  Created by Dunty Vinay Raj on 1/8/14.
//  Copyright (c) 2014 Dunty Vinay Raj. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (ViblioAdditions)

-(BOOL)isValid
{
    if ( self != nil && self.length > 0 )
        return YES;
    return NO;
}

@end
