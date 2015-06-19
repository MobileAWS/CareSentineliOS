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

- (id)initWithProperty:(DeviceProperty *)property AndDeviceName:(NSString *)name{
    self = [super init];
    if (self){
        self.id = property.id;
        self.propertyId = property.propertyId;
        self.deviceId = property.deviceId;
        self.value = property.value;
        self.createdAt = property.createdAt;
        self.deviceName = name;
        self.dismissedAt = property.dismissedAt;
    }
    return self;
}



+(NSDictionary *)getPropertiesMapping{
    return @{
             @"devices_properties_values.id":@"id",
             @"property_id":@"propertyId",
             @"device_id":@"deviceId",
             @"value":@"value",
             @"devices_properties_values.created_at":@"createdAt",
             @"properties.name":@"propertyName",
             @"devices.name":@"deviceName",
             @"dismissed_at":@"dismissedAt"
             };
}

-(void)setCreatedAt:(NSNumber *)createdAt{
    [super setCreatedAt:createdAt];
    _createdAtDate = [notificationsFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[createdAt doubleValue]]];
}

-(void)setDismissedAt:(NSNumber *)dismissedAt{
    [super setDismissedAt:dismissedAt];
    _dismissedAtDate = [notificationsFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[dismissedAt doubleValue]]];
}

@end
