//
//  DeviceProperty.m
//  CareSentineliOS
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DeviceProperty.h"

@implementation DeviceProperty

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"property_id":@"propertyId",
             @"device_id":@"deviceId",
             @"value":@"value",
             @"created_at":@"createdAt"
             };
}

+(NSString *)getTableName{
    return @"devices_properties_values";
}


@end