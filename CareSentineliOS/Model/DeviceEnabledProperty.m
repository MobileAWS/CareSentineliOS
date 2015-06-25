//
//  DeviceCharacteristic.m
//  CareSentineliOS
//
//  Created by Mike on 6/23/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DeviceEnabledProperty.h"

@implementation DeviceEnabledProperty


+(NSString *)getTableName{
    return @"devices_enabled_properties";
}


+(NSDictionary *)getPropertiesMapping{
    return @{
             @"devices_enabled_properties.id":@"id",
             @"property_id":@"propertyId",
             @"device_id":@"deviceId",
             @"enabled":@"enabled",
             @"delay":@"delay",
             @"properties.name":@"name",
             };
}


-(BOOL)isEnabled{
    if (self.enabled == nil)
        return TRUE;
    
    return [self.enabled integerValue] != 0;
}
@end
