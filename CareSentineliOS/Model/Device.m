//
//  Device.m
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Device.h"
#import "APBLEDevice.h"
#import "DeviceEnabledProperty.h"
#import "LNConstants.h"
#import "PropertiesDao.h"

@interface Device(){
    BOOL initialized;
    NSArray *characteristics;
}
@end


@implementation Device

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"hw_id":@"hwId",
             @"hw_name":@"hwName",             
             @"uuid":@"uuid",
             @"site_id":@"siteId",
             @"customer_id":@"customerId",
             @"ignored":@"ignored",
             @"user_id":@"userId",
             @"created_at":@"createdAt"
             };
}

+(NSString *)getTableName{
    return @"devices";
}


-(BOOL)isIgnored{
        if(self.ignored == nil || [self.ignored integerValue] == 0)
            return NO;
        else
            return YES;
}

-(NSArray *)getChangedSwitch:(uint16_t)value{
    
    
    NSMutableArray *switchChanges = [[NSMutableArray alloc]init];
    NSString *valueString = @"value";
    NSString *propertyName = @"propertyName";
    NSString *on = @"On";
    NSString *off = @"Off";
    
    /** Bed sensor */

    BOOL valueEnabled = [self getCharacteristicEnabled:BED_SENSOR_PROPERTY_NAME];
    if (self.bedSensorActivated && (value & APSensorValuesBedLow)){
        self.bedSensorActivated = false;
        if (valueEnabled == TRUE){
                [switchChanges addObject:@{propertyName:BED_SENSOR_PROPERTY_NAME,valueString:off}];
        }
    }
    
    if (!self.bedSensorActivated && (value & APSensorValuesBedHigh)){
        self.bedSensorActivated = true;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:BED_SENSOR_PROPERTY_NAME,valueString:on}];
        }
    }
    
    /* Chair sensor */

    valueEnabled = [self getCharacteristicEnabled:CHAIR_SENSOR_PROPERTY_NAME];

    if (self.chairSensorActivated && (value & APSensorValuesChairLow)){
        self.chairSensorActivated = false;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:CHAIR_SENSOR_PROPERTY_NAME,valueString:off}];
        }
    }

    
    if (!self.chairSensorActivated && (value & APSensorValuesChairHigh)){
        self.chairSensorActivated = true;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:CHAIR_SENSOR_PROPERTY_NAME,valueString:on}];
        }
    }
    
    /* Toilet Sensor */
    valueEnabled = [self getCharacteristicEnabled:TOILET_SENSOR_PROPERTY_NAME];
    if (self.toiletSensorActivated && (value & APSensorValuesToiletLow)){
        self.toiletSensorActivated = false;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:TOILET_SENSOR_PROPERTY_NAME,valueString:off}];
        }
    }
    
    if (!self.toiletSensorActivated && (value & APSensorValuesToiletHigh)){
        self.toiletSensorActivated = true;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:TOILET_SENSOR_PROPERTY_NAME,valueString:on}];
        }
    }

    /* Incontinence Sensor */
    valueEnabled = [self getCharacteristicEnabled:INCONTINENCE_SENSOR_PROPERTY_NAME];
    if (self.incontinenceSensorActivated && (value & APSensorValuesDampnessLow)){
        self.incontinenceSensorActivated = false;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:INCONTINENCE_SENSOR_PROPERTY_NAME,valueString:off}];
        }
    }
    
    if (!self.incontinenceSensorActivated && (value & APSesnorValuesDampnessHigh)){
        self.incontinenceSensorActivated = true;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:INCONTINENCE_SENSOR_PROPERTY_NAME,valueString:on}];
        }
    }
    
    
     /* Call Sensor */
    valueEnabled = [self getCharacteristicEnabled:CALL_SENSOR_PROPERTY_NAME];
    if (self.callSensorActivated && (value & APSensorValuesCallLow)){
        self.callSensorActivated = false;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:CALL_SENSOR_PROPERTY_NAME,valueString:off}];
        }
    }
    
    if (!self.callSensorActivated && (value & APSensorValuesCallHigh)){
        self.callSensorActivated = true;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:CALL_SENSOR_PROPERTY_NAME,valueString:on}];
        }
    }
    
    
    /* Portal Sensor */
    valueEnabled = [self getCharacteristicEnabled:PORTAL_SENSOR_PROPERTY_NAME];
    if (self.portalSensorActivated && (value & APSensorValuesPortalLow)){
        self.portalSensorActivated = false;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:PORTAL_SENSOR_PROPERTY_NAME,valueString:off}];
        }
    }
    
    if (!self.portalSensorActivated && (value & APSensorValuesPortalHigh)){
        self.portalSensorActivated = true;
        if (valueEnabled == TRUE){
            [switchChanges addObject:@{propertyName:PORTAL_SENSOR_PROPERTY_NAME,valueString:on}];
        }
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

-(UIImage *)getImageForBattery{
    
    if (self.deviceDescriptor == nil) {
        return [UIImage imageNamed:@"battery4"];
    }
    

    
    if (self.deviceDescriptor.batteryPercent > 75){
        return [UIImage imageNamed:@"battery4"];
    }
    
    if (self.deviceDescriptor.batteryPercent > 50){
        return [UIImage imageNamed:@"battery3"];
    }
    
    if (self.deviceDescriptor.batteryPercent > 25){
        return [UIImage imageNamed:@"battery2"];
    }
    
    return [UIImage imageNamed:@"battery1"];
    
}

-(UIImage *)getImageForSignal{
    
    if (self.deviceDescriptor == nil) {
        return [UIImage imageNamed:@"wifi3"];
    }
    
    
    if (self.deviceDescriptor.signalPercent > 66) {
        return [UIImage imageNamed:@"wifi3"];
    }

    
    if (self.deviceDescriptor.signalPercent > 33) {
        return [UIImage imageNamed:@"wifi2"];
    }


    return [UIImage imageNamed:@"wifi1"];
}


-(NSString *)getTemperature{
    if (self.deviceDescriptor == nil){
        return @"N/A";
    }
    
    return self.deviceDescriptor.temperature;
}

-(NSArray *)getCharacteristics{
    
    if (self->characteristics){
        return characteristics;
    }
    characteristics = [PropertiesDao listPropertiesForDevice:self.id];
    return characteristics;
}

-(BOOL)getCharacteristicEnabled:(NSString *)characteristicName{
    NSArray *tmpCharacteristics = [self getCharacteristics];
    DeviceEnabledProperty *tmpChar = nil;
    for(int i = 0; i < tmpCharacteristics.count; i++){
        tmpChar = ((DeviceEnabledProperty *)[tmpCharacteristics objectAtIndex:i]);
        NSString *name = tmpChar.name;
        if ([name isEqualToString:characteristicName]){
            return [tmpChar isEnabled];
        }
    }
    return true;
}

-(void)switchCharacteristicStatus:(NSString *)characteristicName{
    NSArray *tmpCharacteristics = [self getCharacteristics];
    DeviceEnabledProperty *tmpChar = nil;
    for(int i = 0; i < tmpCharacteristics.count; i++){
        tmpChar = ((DeviceEnabledProperty *)[tmpCharacteristics objectAtIndex:i]);
        NSString *name = tmpChar.name;
        if ([name isEqualToString:characteristicName]){
            tmpChar.enabled = [[NSNumber alloc] initWithInt: [tmpChar isEnabled] ? 0 : 1];
            [PropertiesDao saveDeviceEnabledProperty:tmpChar];
            return;
        }
    }
    return;
}

-(void)setupCharacteristics{
    self->characteristics = [PropertiesDao initPropertiesForDevice:self.id];
}
@end
