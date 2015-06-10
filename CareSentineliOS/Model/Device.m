//
//  Device.m
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Device.h"
#import "APBLEDevice.h"

@interface Device()
@end


@implementation Device

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"hw_id":@"hwId",
             @"site_id":@"siteId",
             @"customer_id":@"customerId",
             @"created_at":@"createdAt"
             };
}

+(NSString *)getTableName{
    return @"devices";
}

-(NSString *)getChangedSwitch:(uint16_t)value{
    
    NSLog([NSString stringWithFormat:@"Switch Value Is => %d",value]);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    /** Bed sensor */
    if (self.bedSensorActivated && (value & APSensorValuesBedLow)){
        self.bedSensorActivated = false;
        [result appendString:@"Bed Sensor Has Been Turned Off\n"] ;
    }
    
    if (!self.bedSensorActivated && (value & APSensorValuesBedHigh)){
        self.bedSensorActivated = true;
        [result appendString:@"Bed Sensor Has Been Turned On\n"] ;
    }

    /* Chair sensor */
    if (self.chairSensorActivated && (value & APSensorValuesChairLow)){
        self.chairSensorActivated = false;
        [result appendString:@"Chair Sensor Has Been Turned Off\n"] ;
    }

    
    if (!self.chairSensorActivated && (value & APSensorValuesChairHigh)){
        self.chairSensorActivated = true;
        [result appendString:@"Chair Sensor Has Been Turned On\n"] ;
    }
    
    /* Toilet Sensor */
    if (self.toiletSensorActivated && (value & APSensorValuesToiletLow)){
        self.toiletSensorActivated = false;
        [result appendString:@"Toilet Sensor Has Been Turned Off\n"] ;
    }
    
    if (!self.toiletSensorActivated && (value & APSensorValuesToiletHigh)){
        self.toiletSensorActivated = true;
        [result appendString:@"Toilet Sensor Has Been Turned Off\n"] ;
    }

    /* Incontinence Sensor */
    if (self.incontinenceSensorActivated && (value & APSensorValuesDampnessLow)){
        self.incontinenceSensorActivated = false;
        [result appendString:@"Incontinence Sensor Has Been Turned Off\n"] ;
    }
    
    if (!self.incontinenceSensorActivated && (value & APSesnorValuesDampnessHigh)){
        self.incontinenceSensorActivated = true;
        [result appendString:@"Incontinence Sensor Has Been Turned On\n"] ;
    }
    
    
    if ([result length] > 0){
        [result deleteCharactersInRange:NSMakeRange([result length] -  1, 1)];
         return result;
    }

    return nil;
}




@end
