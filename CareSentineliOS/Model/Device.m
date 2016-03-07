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
#import "LNSensorLockManager.h"

@interface Device(){
    NSArray *characteristics;
}
@end


@implementation Device{
    LNSensorLockManager *lockManager;
}

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"hw_id":@"hwId",
             @"hw_name":@"hwName",
             @"type":@"type",
             @"uuid":@"uuid",
             @"ignored":@"ignored",
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
    if (self->lockManager == nil) {
        self->lockManager = [[LNSensorLockManager alloc] init];
    }
    NSMutableArray *switchChanges = [[NSMutableArray alloc]init];
    NSString *valueString = @"value";
    NSString *propertyName = @"propertyName";
    NSString *baseName = @"baseName";
    NSString *on = @"On";
    NSString *off = @"Off";
    BOOL onEnabled, offEnabled;
    
    
    if([self.type intValue] == APDeviceTypeCareSentinel){
        /** Bed sensor */
        BOOL valueEnabled = [self getCharacteristicEnabled:BED_SENSOR_PROPERTY_NAME];
        onEnabled = [ON_ENABLED_SENSORS containsObject:BED_SENSOR_PROPERTY_NAME];
        offEnabled = [OFF_ENABLED_SENSORS containsObject:BED_SENSOR_PROPERTY_NAME];
        
        if (self.bedSensorActivated && (value & APSensorValuesBedLow)){
            self.bedSensorActivated = false;
            
            if (valueEnabled == TRUE && offEnabled == TRUE){
                [switchChanges addObject:@{baseName:BED_SENSOR_PROPERTY_NAME,propertyName:BED_SENSOR_PROPERTY_KEY,valueString:off}];
            }
        }
        
        if (!self.bedSensorActivated && (value & APSensorValuesBedHigh)){
            self.bedSensorActivated = true;
            if (valueEnabled == TRUE && onEnabled == TRUE){
                [switchChanges addObject:@{baseName:BED_SENSOR_PROPERTY_NAME,propertyName:BED_SENSOR_PROPERTY_KEY,valueString:on}];
            }
        }
        
        /* Chair sensor */
        
        valueEnabled = [self getCharacteristicEnabled:CHAIR_SENSOR_PROPERTY_NAME];
        onEnabled = [ON_ENABLED_SENSORS containsObject:CHAIR_SENSOR_PROPERTY_NAME];
        offEnabled = [OFF_ENABLED_SENSORS containsObject:CHAIR_SENSOR_PROPERTY_NAME];
        
        
        if (self.chairSensorActivated && (value & APSensorValuesChairLow)){
            self.chairSensorActivated = false;
            if (valueEnabled == TRUE && offEnabled == TRUE){
                [switchChanges addObject:@{baseName:CHAIR_SENSOR_PROPERTY_NAME,propertyName:CHAIR_SENSOR_PROPERTY_KEY,valueString:off}];
            }
        }
        
        
        if (!self.chairSensorActivated && (value & APSensorValuesChairHigh)){
            self.chairSensorActivated = true;
            if (valueEnabled == TRUE && onEnabled == TRUE){
                [switchChanges addObject:@{baseName:CHAIR_SENSOR_PROPERTY_NAME,propertyName:CHAIR_SENSOR_PROPERTY_KEY,valueString:on}];
            }
        }
        
        /* Toilet Sensor */
        valueEnabled = [self getCharacteristicEnabled:TOILET_SENSOR_PROPERTY_NAME];
        onEnabled = [ON_ENABLED_SENSORS containsObject:TOILET_SENSOR_PROPERTY_NAME];
        offEnabled = [OFF_ENABLED_SENSORS containsObject:TOILET_SENSOR_PROPERTY_NAME];
        
        if (self.toiletSensorActivated && (value & APSensorValuesToiletLow)){
            self.toiletSensorActivated = false;
            if (valueEnabled == TRUE && offEnabled == TRUE){
                [switchChanges addObject:@{baseName:TOILET_SENSOR_PROPERTY_NAME,propertyName:TOILET_SENSOR_PROPERTY_KEY,valueString:off}];
            }
        }
        
        if (!self.toiletSensorActivated && (value & APSensorValuesToiletHigh)){
            self.toiletSensorActivated = true;
            if (valueEnabled == TRUE && onEnabled == TRUE){
                [switchChanges addObject:@{baseName:TOILET_SENSOR_PROPERTY_NAME,propertyName:TOILET_SENSOR_PROPERTY_KEY,valueString:on}];
            }
        }
        
        /* Incontinence Sensor */
        valueEnabled = [self getCharacteristicEnabled:INCONTINENCE_SENSOR_PROPERTY_NAME];
        onEnabled = [ON_ENABLED_SENSORS containsObject:INCONTINENCE_SENSOR_PROPERTY_NAME];
        offEnabled = [OFF_ENABLED_SENSORS containsObject:INCONTINENCE_SENSOR_PROPERTY_NAME];
        
        if (self.incontinenceSensorActivated && (value & APSensorValuesDampnessLow)){
            self.incontinenceSensorActivated = false;
            if (valueEnabled == TRUE && offEnabled == TRUE){
                [switchChanges addObject:@{baseName:INCONTINENCE_SENSOR_PROPERTY_NAME,propertyName:INCONTINENCE_SENSOR_PROPERTY_KEY,valueString:off}];
            }
        }
        
        if (!self.incontinenceSensorActivated && (value & APSesnorValuesDampnessHigh)){
            self.incontinenceSensorActivated = true;
            if (valueEnabled == TRUE && onEnabled == TRUE){
                [switchChanges addObject:@{baseName:INCONTINENCE_SENSOR_PROPERTY_NAME,propertyName:INCONTINENCE_SENSOR_PROPERTY_KEY,valueString:on}];
            }
        }
        
        
        /* Call Sensor */
        valueEnabled = [self getCharacteristicEnabled:CALL_SENSOR_PROPERTY_NAME];
        onEnabled = [ON_ENABLED_SENSORS containsObject:CALL_SENSOR_PROPERTY_NAME];
        offEnabled = [OFF_ENABLED_SENSORS containsObject:CALL_SENSOR_PROPERTY_NAME];
        
        if (self.callSensorActivated && (value & APSensorValuesCallHigh)){
            self.callSensorActivated = false;
            if (valueEnabled == TRUE && offEnabled == TRUE){
                [switchChanges addObject:@{baseName:CALL_SENSOR_PROPERTY_NAME,propertyName:CALL_SENSOR_PROPERTY_KEY,valueString:off}];
            }
        }
        
        if (!self.callSensorActivated && (value & APSensorValuesCallLow)){
            self.callSensorActivated = true;
            if (valueEnabled == TRUE && onEnabled == TRUE){
                [switchChanges addObject:@{baseName:CALL_SENSOR_PROPERTY_NAME,propertyName:CALL_SENSOR_PROPERTY_KEY,valueString:on}];
            }
        }
        
        
        /* Portal Sensor */
        valueEnabled = [self getCharacteristicEnabled:PORTAL_SENSOR_PROPERTY_NAME];
        onEnabled = [ON_ENABLED_SENSORS containsObject:PORTAL_SENSOR_PROPERTY_NAME];
        offEnabled = [OFF_ENABLED_SENSORS containsObject:PORTAL_SENSOR_PROPERTY_NAME];
        
        if (self.portalSensorActivated && (value & APSensorValuesPortalLow)){
            self.portalSensorActivated = false;
            if (valueEnabled == TRUE && offEnabled == TRUE){
                [switchChanges addObject:@{baseName:PORTAL_SENSOR_PROPERTY_NAME,propertyName:PORTAL_SENSOR_PROPERTY_KEY,valueString:off}];
            }
        }
        
        if (!self.portalSensorActivated && (value & APSensorValuesPortalHigh)){
            self.portalSensorActivated = true;
            if (valueEnabled == TRUE && onEnabled == TRUE){
                [switchChanges addObject:@{baseName:PORTAL_SENSOR_PROPERTY_NAME,propertyName:PORTAL_SENSOR_PROPERTY_KEY,valueString:on}];
            }
        }
    }
    
    if([self.type intValue] == APDeviceTypeCareCom){
        
        /* Fall Button */
        BOOL valueEnabled = [self getCharacteristicEnabled:FALL_BUTTON_PROPERTY_NAME];
        BOOL onEnabled = [ON_ENABLED_SENSORS containsObject:FALL_BUTTON_PROPERTY_NAME];
        BOOL offEnabled = [OFF_ENABLED_SENSORS containsObject:FALL_BUTTON_PROPERTY_NAME];
        
        NSString *sensorKey = [NSString stringWithFormat:@"%@.%d.%@", self.id, APDeviceTypeCareCom,FALL_BUTTON_PROPERTY_NAME];
        /** Check if this sensor is currently locked for this device, if it is, 
         *  just skip changes validations, we assume they're ingored, while the sensor is locked. 
         **/
        if ([self->lockManager isSensorLocked:sensorKey] == NO) {
            if (self.fallButtonActivated && (value & APCareComValuesFallLow)){
                self.fallButtonActivated = false;
                if (valueEnabled == TRUE && offEnabled == TRUE){
                    [switchChanges addObject:@{baseName:FALL_BUTTON_PROPERTY_NAME,propertyName:FALL_BUTTON_PROPERTY_KEY,valueString:off}];
                    if (self.initialized) {
                        [self->lockManager lockNotificationsForSensor:sensorKey];
                    }
                }
            }
            
            if (!self.fallButtonActivated && (value & APCareComValuesFallHigh)){
                self.fallButtonActivated = true;
                if (valueEnabled == TRUE && onEnabled == TRUE){
                    [switchChanges addObject:@{baseName:FALL_BUTTON_PROPERTY_NAME,propertyName:FALL_BUTTON_PROPERTY_KEY,valueString:on}];
                    if (self.initialized) {
                        [self->lockManager lockNotificationsForSensor:sensorKey];
                    }
                }
            }
        }
    }
    
    /** Only return changes if the device has been already initialized */
    if (!self.initialized) {
        self->_initialized = true;
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
    self->characteristics = [PropertiesDao initPropertiesForDevice:self.id withType:[self.type integerValue]];
}

-(BOOL)isOnForSwitch:(NSString *)name{
    
    if ([name isEqualToString:BED_SENSOR_PROPERTY_NAME]) {
        return self.bedSensorActivated;
    }
    
    if ([name isEqualToString:CHAIR_SENSOR_PROPERTY_NAME]) {
        return self.chairSensorActivated;
    }
    
    if ([name isEqualToString:TOILET_SENSOR_PROPERTY_NAME]) {
        return self.toiletSensorActivated;
    }
    
    if ([name isEqualToString:INCONTINENCE_SENSOR_PROPERTY_NAME]) {
        return self.incontinenceSensorActivated;
    }
    
    if ([name isEqualToString:CALL_SENSOR_PROPERTY_NAME]) {
        return self.callSensorActivated;
    }
    
    if ([name isEqualToString:PORTAL_SENSOR_PROPERTY_NAME]) {
        return self.portalSensorActivated;
    }

    if ([name isEqualToString:FALL_BUTTON_PROPERTY_NAME]) {
        return self.fallButtonActivated;
    }

    
    return false;
}

- (NSDictionary *)getRequestData{
    return @{@"hw_id": self.hwId,
             @"name": self.hwName,
             @"device_name":self.name
             };
}

@end
