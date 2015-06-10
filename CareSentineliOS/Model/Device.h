//
//  Device.h
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Device : NSObject <BaseModel>
    +(NSString *)getTableName;
    +(NSDictionary *)getPropertiesMapping;
    -(NSString *)getChangedSwitch:(uint16_t)value;
    @property NSNumber *id;
    @property NSString *name;
    @property NSString *hwId;
    @property NSString *siteId;
    @property NSNumber *customerId;
    @property NSNumber *createdAt;
    @property BOOL bedSensorActivated;
    @property BOOL chairSensorActivated;
    @property BOOL toiletSensorActivated;
    @property BOOL incontinenceSensorActivated;

@end
