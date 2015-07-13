//
//  DevicesDao.h
//  CareSentineliOS
//
//  Created by Mike on 7/12/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"

@interface DevicesDao : NSObject
+(void)deleteDeviceData:(Device *)device;
@end
