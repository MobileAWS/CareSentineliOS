//
//  LNConstants.h
//  CareSentineliOS
//
//  Created by Mike on 6/24/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNConstants : NSObject
extern NSString * const BED_SENSOR_PROPERTY_NAME;
extern NSString * const CHAIR_SENSOR_PROPERTY_NAME;
extern NSString * const TOILET_SENSOR_PROPERTY_NAME;
extern NSString * const INCONTINENCE_SENSOR_PROPERTY_NAME;
extern NSString * const CALL_SENSOR_PROPERTY_NAME;
extern NSString * const PORTAL_SENSOR_PROPERTY_NAME;
extern NSString * const FALL_BUTTON_PROPERTY_NAME;


extern NSString * const BED_SENSOR_PROPERTY_KEY;
extern NSString * const CHAIR_SENSOR_PROPERTY_KEY;
extern NSString * const TOILET_SENSOR_PROPERTY_KEY;
extern NSString * const INCONTINENCE_SENSOR_PROPERTY_KEY;
extern NSString * const CALL_SENSOR_PROPERTY_KEY;
extern NSString * const PORTAL_SENSOR_PROPERTY_KEY;
extern NSString * const FALL_BUTTON_PROPERTY_KEY;

extern NSArray * ON_ENABLED_SENSORS;
extern NSArray * OFF_ENABLED_SENSORS;
extern NSArray * SMS_ENABLED_SENSORS;
extern NSArray * SMS_ENABLED_DEVICE_TYPES;
extern NSDictionary *PROPERTY_KEYS_MAPPING;

+(void)initConstants;

@end
