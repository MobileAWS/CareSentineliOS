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
#import "HexColor.h"

@implementation UIResources
    UIColor *buttonBorderColor = nil;
    CGColorRef buttonBorderColorRef;
    CGColorRef baseBackgroundColorRef =nil;
    UIColor *selectionBackgroundColorRef = nil;
    UIColor *baseBackgroundColor =nil;
    UIColor *baseBackgroundColorDarker = nil;
    UIColor *greenBaseColor =nil;
    UIImage *noBatteryImage = nil;
    UIImage *noSignalImage = nil;
    UIImage *batteryImage = nil;
    UIImage *signalImage = nil;
    NSDateFormatter *notificationsFormatter;
    NSArray *deviceTypesImages;


+(void)initResources{
        greenBaseColor = [UIColor colorWithHexString:@"#3783BF"];
        buttonBorderColor = [UIColor colorWithHexString:@"#5FABDD"];
        buttonBorderColorRef = [buttonBorderColor CGColor];
        baseBackgroundColor = [UIColor colorWithHexString:@"#5FABDD"];
        baseBackgroundColorDarker = [UIColor colorWithHexString:@"3783BF"];
    
        selectionBackgroundColorRef = [UIColor colorWithRed:0.9 green:1 blue:0.9 alpha:1];
        baseBackgroundColorRef = [baseBackgroundColor CGColor];
        batteryImage = [UIImage imageNamed:@"battery4"];
        noBatteryImage = [UIImage imageNamed:@"nobattery"];
        signalImage = [UIImage imageNamed:@"wifi3"];
        noSignalImage = [UIImage imageNamed:@"offline"];
        notificationsFormatter = [[NSDateFormatter alloc] init];
        [notificationsFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        deviceTypesImages = @[@"CS01-01-photo",@"CS02-02-photo"];
}
@end
