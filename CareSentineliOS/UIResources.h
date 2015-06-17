//
//  UIResources.h
//  CareSentineliOS
//
//  Created by Mike on 6/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIKit/UIKit.h"

@interface UIResources : NSObject
extern CGColorRef buttonBorderColor;
extern CGColorRef baseBackgroundColorRef;
extern UIColor *selectionBackgroundColorRef;
extern UIColor *baseBackgroundColor;
extern UIImage *noBatteryImage;
extern UIImage *noSignalImage;
extern UIImage *batteryImage;
extern UIImage *signalImage;
extern NSDateFormatter *notificationsFormatter;

+(void)initResources;
@end
