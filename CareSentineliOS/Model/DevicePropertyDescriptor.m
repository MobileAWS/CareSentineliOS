//
//  DevicePropertyDescriptor.m
//  CareSentineliOS
//
//  Created by Mike on 6/12/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DevicePropertyDescriptor.h"
#import "UIResources.h"

@implementation DevicePropertyDescriptor

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"property_id":@"propertyId",
             @"device_id":@"deviceId",
             @"value":@"value",
             @"devices_properties_values.created_at":@"createdAt",
             @"properties.name":@"propertyName",
             @"devices.name":@"deviceName"
             };
}

-(void)setCreatedAt:(NSNumber *)createdAt{
    [super setCreatedAt:createdAt];
    _createdAtDate = [notificationsFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[createdAt doubleValue]]];
}
@end
