//
//  LNSwitchChangedDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 7/8/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Device.h"
#import <Foundation/Foundation.h>

@protocol LNSwitchChangedDelegate
-(void)switchChangedForDevice:(Device *)device;
@end
