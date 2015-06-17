//
//  Device.m
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Device.h"
#import "APBLEDevice.h"

@interface Device(){
    BOOL initialized;
}
@end


@implementation Device

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"hw_id":@"hwId",
             @"site_id":@"siteId",
             @"customer_id":@"customerId",
             @"user_id":@"userId",
             @"created_at":@"createdAt"
             };
}

+(NSString *)getTableName{
    return @"devices";
}

-(NSArray *)getChangedSwitch:(uint16_t)value{
    
    
    
    NSMutableArray *switchChanges = [[NSMutableArray alloc]init];
    NSMutableString *message = [[NSMutableString alloc] init];
    NSString *valueString = @"value";
    NSString *propertyName = @"propertyName";
    NSString *on = @"On";
    NSString *off = @"Off";
    
    /** Bed sensor */
    if (self.bedSensorActivated && (value & APSensorValuesBedLow)){
        self.bedSensorActivated = false;
        [switchChanges addObject:@{propertyName:@"Bed Sensor",valueString:off}];
    }
    
    if (!self.bedSensorActivated && (value & APSensorValuesBedHigh)){
        self.bedSensorActivated = true;
        [switchChanges addObject:@{propertyName:@"Bed Sensor",valueString:on}];
        [message appendString:@"Bed Sensor Has Been Turned On\n"] ;
    }

    /* Chair sensor */
    if (self.chairSensorActivated && (value & APSensorValuesChairLow)){
        self.chairSensorActivated = false;
        [switchChanges addObject:@{propertyName:@"Chair Sensor",valueString:off}];
    }

    
    if (!self.chairSensorActivated && (value & APSensorValuesChairHigh)){
        self.chairSensorActivated = true;
        [switchChanges addObject:@{propertyName:@"Chair Sensor",valueString:on}];
    }
    
    /* Toilet Sensor */
    if (self.toiletSensorActivated && (value & APSensorValuesToiletLow)){
        self.toiletSensorActivated = false;
        [switchChanges addObject:@{propertyName:@"Toilet Sensor",valueString:off}];
    }
    
    if (!self.toiletSensorActivated && (value & APSensorValuesToiletHigh)){
        self.toiletSensorActivated = true;
        [switchChanges addObject:@{propertyName:@"Toilet Sensor",valueString:on}];
    }

    /* Incontinence Sensor */
    if (self.incontinenceSensorActivated && (value & APSensorValuesDampnessLow)){
        self.incontinenceSensorActivated = false;
        [switchChanges addObject:@{propertyName:@"Incontinence Sensor",valueString:off}];
    }
    
    if (!self.incontinenceSensorActivated && (value & APSesnorValuesDampnessHigh)){
        self.incontinenceSensorActivated = true;
        [switchChanges addObject:@{propertyName:@"Incontinence Sensor",valueString:on}];
    }
    
    /** Only return changes if the device has been already initialized */
    if (!self->initialized) {
        self->initialized = true;
        [switchChanges removeAllObjects];
        switchChanges = nil;
        return nil;
    }
    
    return switchChanges;
}




@end
