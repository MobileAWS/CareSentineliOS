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
+(void)initResources;
@end
