//
//  LNConstants.m
//  CareSentineliOS
//
//  Created by Mike on 6/24/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "LNConstants.h"

@implementation LNConstants
    NSString * const BED_SENSOR_PROPERTY_NAME = @"Bed Sensor";
    NSString * const CHAIR_SENSOR_PROPERTY_NAME = @"Chair Sensor";
    NSString * const TOILET_SENSOR_PROPERTY_NAME = @"Toilet Sensor";
    NSString * const INCONTINENCE_SENSOR_PROPERTY_NAME = @"Incontinence Sensor";
    NSString * const CALL_SENSOR_PROPERTY_NAME = @"Call Sensor";
    NSString * const PORTAL_SENSOR_PROPERTY_NAME = @"Portal Sensor";

    NSString * const FALL_BUTTON_PROPERTY_NAME = @"Fall Button";

    NSString * const BED_SENSOR_PROPERTY_KEY = @"bed.sensor";
    NSString * const CHAIR_SENSOR_PROPERTY_KEY = @"chair.sensor";
    NSString * const TOILET_SENSOR_PROPERTY_KEY = @"toilet.sensor";
    NSString * const INCONTINENCE_SENSOR_PROPERTY_KEY = @"incontinence.sensor";
    NSString * const CALL_SENSOR_PROPERTY_KEY = @"call.sensor";
    NSString * const PORTAL_SENSOR_PROPERTY_KEY = @"portal.sensor";

    NSString * const FALL_BUTTON_PROPERTY_KEY = @"fall.button";

    NSArray * ON_ENABLED_SENSORS;
    NSArray * OFF_ENABLED_SENSORS;
    NSDictionary * PROPERTY_KEYS_MAPPING;
    NSArray * SMS_ENABLED_SENSORS;
    NSArray * SMS_ENABLED_DEVICE_TYPES;


+(void)initConstants{
   ON_ENABLED_SENSORS = @[BED_SENSOR_PROPERTY_NAME,CHAIR_SENSOR_PROPERTY_NAME,TOILET_SENSOR_PROPERTY_NAME,INCONTINENCE_SENSOR_PROPERTY_NAME,CALL_SENSOR_PROPERTY_NAME,PORTAL_SENSOR_PROPERTY_NAME,FALL_BUTTON_PROPERTY_NAME];
    
    OFF_ENABLED_SENSORS = @[BED_SENSOR_PROPERTY_NAME,CHAIR_SENSOR_PROPERTY_NAME,TOILET_SENSOR_PROPERTY_NAME];
    
    PROPERTY_KEYS_MAPPING = @{BED_SENSOR_PROPERTY_NAME:BED_SENSOR_PROPERTY_KEY,
                              CHAIR_SENSOR_PROPERTY_NAME:CHAIR_SENSOR_PROPERTY_KEY,
                              TOILET_SENSOR_PROPERTY_NAME:TOILET_SENSOR_PROPERTY_KEY,
                              INCONTINENCE_SENSOR_PROPERTY_NAME:INCONTINENCE_SENSOR_PROPERTY_KEY,
                              CALL_SENSOR_PROPERTY_NAME:CALL_SENSOR_PROPERTY_KEY,
                              PORTAL_SENSOR_PROPERTY_NAME:PORTAL_SENSOR_PROPERTY_KEY,
                              FALL_BUTTON_PROPERTY_NAME:FALL_BUTTON_PROPERTY_KEY};
    
    SMS_ENABLED_SENSORS = @[FALL_BUTTON_PROPERTY_NAME];
}

@end
