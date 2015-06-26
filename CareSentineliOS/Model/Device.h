//
//  Device.h
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "DevicePropertyDescriptor.h"
#import "APBLEDevice.h"

@interface Device : NSObject <BaseModel>

    +(NSString *)getTableName;
    +(NSDictionary *)getPropertiesMapping;
    -(NSArray *)getChangedSwitch:(uint16_t)value;
    -(BOOL)isIgnored;
    -(UIImage *)getImageForBattery;
    -(UIImage *)getImageForSignal;
    -(NSString *) getTemperature;
    -(NSArray *) getCharacteristics;
    -(void)switchCharacteristicStatus:(NSString *)name;
    -(void)setupCharacteristics;

    /* Datbase properties */
    @property NSNumber *id;
    @property NSString *name;
    @property NSString *hwId;
    @property NSString *hwName;
    @property NSString *uuid;
    @property NSNumber *siteId;
    @property NSNumber *customerId;
    @property NSNumber *userId;
    @property NSNumber *createdAt;
    @property NSNumber *ignored;

    /* Control & Runtime properties */
    @property BOOL bedSensorActivated;
    @property BOOL chairSensorActivated;
    @property BOOL toiletSensorActivated;
    @property BOOL incontinenceSensorActivated;
    @property BOOL callSensorActivated;
    @property BOOL portalSensorActivated;
    @property BOOL connected;
    @property DevicePropertyDescriptor *lastPropertyChange;
    @property NSString *lastPropertyMessage;
    @property (weak) APBLEDevice *deviceDescriptor;



@end
