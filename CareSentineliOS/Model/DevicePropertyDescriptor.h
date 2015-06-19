//
//  DevicePropertyDescriptor.h
//  CareSentineliOS
//
//  Created by Mike on 6/12/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DeviceProperty.h"

@interface DevicePropertyDescriptor : DeviceProperty
    @property NSString *propertyName;
    @property NSString *deviceName;
    @property (readonly) NSString *createdAtDate;
    @property (readonly) NSString *dismissedAtDate;
- (id)initWithProperty:(DeviceProperty *)property AndDeviceName:(NSString *)name;
@end
