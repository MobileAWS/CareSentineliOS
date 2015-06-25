//
//  DeviceCharacteristic.h
//  CareSentineliOS
//
//  Created by Mike on 6/23/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface DeviceEnabledProperty : NSObject <BaseModel>
    @property NSNumber *id;
    @property NSNumber *propertyId;
    @property NSNumber *deviceId;
    @property NSString *name;
    @property NSNumber *enabled;
    @property NSNumber *delay;
    -(BOOL)isEnabled;
@end
