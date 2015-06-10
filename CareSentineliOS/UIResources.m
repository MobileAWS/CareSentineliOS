//
//  UIResources.m
//  CareSentineliOS
//
//  Created by Mike on 6/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "UIResources.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@implementation UIResources
    CGColorRef buttonBorderColor = nil;
    CGColorRef baseBackgroundColorRef =nil;
    UIColor *selectionBackgroundColorRef = nil;
    UIColor *baseBackgroundColor =nil;
+(void)initResources{
        buttonBorderColor = [[UIColor colorWithRed:0.415 green:0.9 blue:(0.81) alpha:1]CGColor];
        baseBackgroundColor = [UIColor colorWithRed:0.21 green:0.35 blue:(0.32) alpha:1];
        selectionBackgroundColorRef = [UIColor colorWithRed:0.9 green:1 blue:0.9 alpha:1];
        baseBackgroundColorRef = [baseBackgroundColor CGColor];
}
@end
