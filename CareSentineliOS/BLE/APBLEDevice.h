//
//  APBLEDevice.h
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 4/5/13.
//  Copyright (c) 2013 AppPotential, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

// -- *** IMPORTANT *** MUST be kept in synch (same order and # of entries) with BLEDeviceTypesList PLIST
enum {
    APDeviceTypeUnknown      = 0,
    APDeviceTypeCareSentinel = 1,
    APDeviceTypeCareCom = 2
} typedef APDeviceType;

enum {
    APSensorHistoryClearReasonNormal     = 0,
    APSensorHistoryClearReasonUserAction = 1
} typedef APSensorHistoryClearReason;


enum {
    APSensorTypeUnknown  = 0,
    APSensorTypeBed      = 1,
    APSensorTypeChair    = 2,
    APSensorTypeToilet   = 3,
    APSensorTypeDampness = 4,
    APSensorTypeCall     = 5,
    APSensorTypePortal   = 6
} typedef APSensorType;     // -- These need to be sequential, starting with 0 as unknown.

/** Sensor CS1 Bit Values */
enum {
    APSensorValuesBedLow       = (2 >> 1),
    APSensorValuesChairLow     = 2,
    APSensorValuesToiletLow    = (2 << 2),
    APSensorValuesDampnessLow  = (2 << 1),
    APSensorValuesCallLow      = (2 << 9),
    APSensorValuesPortalLow    = (2 << 8),
    APSensorValuesBedHigh      = (2 << 3),
    APSensorValuesChairHigh    = (2 << 4),
    APSensorValuesToiletHigh   = (2 << 6),
    APSesnorValuesDampnessHigh = (2 << 5),
    APSensorValuesCallHigh     = (2 << 7),
    APSensorValuesPortalHigh   = (2 << 10)
} typedef APSensorValues;

/** CareCom CS2 Bit Values */
enum {
    APCareComValuesFallLow    = (2 << 1),
    APCareComValuesFallHigh   = (2 >> 1)
} typedef APCareComValues;

enum {
    APSensorTriggerBed      = APSensorValuesBedHigh,         // ##############
    APSensorTriggerChair    = APSensorValuesChairHigh,       // ##############
    APSensorTriggerToilet   = APSensorValuesToiletHigh,      // ##############
    APSensorTriggerDampness = APSesnorValuesDampnessHigh,
    APSensorTriggerCall     = APSensorValuesCallHigh,
    APSensorTriggerPortal   = APSensorValuesPortalHigh
} typedef APSensorTriggers;

enum {
    APSensorClearBed      = APSensorValuesBedLow,            // ##############
    APSensorClearChair    = APSensorValuesChairLow,          // ##############
    APSensorClearToilet   = APSensorValuesToiletLow,         // ##############
    APSensorClearDampness = APSensorValuesDampnessLow,
    APSensorClearCall     = APSensorValuesCallLow,
    APSensorClearPortal   = APSensorValuesPortalLow
} typedef APSensorClears;


// ==============================================================================
// -- History Class
// ==============================================================================
#define kHistoryEntriesMaxNumber    30
@interface APBLESensorHistoryEntry : NSObject
@property (assign, nonatomic) APSensorType                   sensorType;
@property (strong, nonatomic) NSDate                        *triggerTime;
@property (strong, nonatomic) NSDate                        *clearedTime;
@property (assign, nonatomic) APSensorHistoryClearReason     reason;
@end

// ==============================================================================
// -- Sensor Class
// ==============================================================================
@class APBLESensor;
@protocol APSensorDelegate <NSObject>
@optional
- (void)sensorTriggered:(APBLESensor *)sensor;
- (void)sensorCleared:(APBLESensor *)sensor;
@end
@class APBLEDevice;

////typedef void (^CompletionBlock)(APBLESensor *sensor);

@interface APBLESensor : NSObject
@property (assign,nonatomic) id <APSensorDelegate>     delegate;
@property (assign, nonatomic) APSensorType             type;
@property (strong, nonatomic) NSString                *name;
@property (assign, nonatomic) BOOL                     triggered;
@property (assign, nonatomic) BOOL                     muteTrigger;
@property (assign, nonatomic) NSTimeInterval           triggerDelay;
@property (strong, nonatomic) APBLESensorHistoryEntry *openHistoryEntry;
@property (assign, nonatomic) APBLEDevice             *parentDevice;
@property (assign, nonatomic) NSInteger                alertSoundIndex;
@property (assign, nonatomic) NSInteger                clearSoundIndex;     // -- -1 if no clear soudn option.
////@property (copy, nonatomic)   CompletionBlock          triggeredBlock;  // -- Called after delay period.    ############## REMOVE
@property (readonly)          UIImage                 *image;
@property (readonly)          BOOL                     manualClear;

- (NSString *)sensorTypeString;
////- (void)setTriggeredBlock:(CompletionBlock)triggeredBlock;              // -- Explicit declaration enables auto complete.

// ------------------------------------------------------------------------------
#pragma mark - Class Methods
// ------------------------------------------------------------------------------
+ (NSArray *)sensorTypeLabels;
+ (NSString *)sensorTypeStringForType:(APSensorType)type;
@end

// -- Loon Medical Sensors
#define kUUIDDeviceInfoService   @"180a"
#define kUUIDBatteryService      @"180f"
#define kUUIDBatteryData         @"2a19"
#define kUUIDThermoService       @"1809"
#define kUUIDThermoData          @"2a1c"
#define kUUIDCareSentinelService @"79f7744a-f8e6-4810-8f16-140b6974835d"
#define kUUIDCareSentinelChar    @"64695f25-2326-430a-985f-aa4ae90da42f"
#define kUUIDCareComService      @"4ce30f4c-b14c-49e6-b001-1c83488a9964"
#define kUUIDCareComChar         @"51aa80bf-bc06-43bb-979c-fb4722d4c4e1"

#define kUUIDModelNumber         @"2a24"
#define kUUIDSerialNumber        @"2a25"
#define kUUIDManufacturer        @"2a29"
#define kUUIDFirmwareRevision    @"2a26"
#define kUUIDHardwareRevision    @"2a27"

#define kThermoFlagFahrenheit    0x1
#define kDeviceInvalidTemp       -999.9f

// ==============================================================================
// -- Device Class
// ==============================================================================
@interface APBLEDevice : NSObject
@property (strong, nonatomic) CBPeripheral     *peripheral;
@property (strong, nonatomic) CBService        *thermoService;
@property (strong, nonatomic) CBService        *batteryService;
@property (strong, nonatomic) CBService        *switchService;

@property (strong, nonatomic) NSUUID           *identifier;
@property (readonly)          NSString         *UUIDString;
@property (assign, nonatomic) APDeviceType      type;
@property (strong, nonatomic) NSString         *typeString;
@property (strong, nonatomic) NSString         *name;
@property (strong, nonatomic) NSString         *model;
@property (strong, nonatomic) NSString         *serialNumber;
@property (strong, nonatomic) NSString         *firmwareRevision;
@property (strong, nonatomic) NSString         *hardwareRevision;
@property (strong, nonatomic) NSString         *manufacturer;
@property (assign, nonatomic) NSInteger         RSSI;
@property (nonatomic)          int               batteryPercent;
@property (assign, nonatomic) int               signalPercent;
@property (assign, nonatomic) BOOL              batteryLow;
@property (assign, nonatomic) BOOL              triggered;
@property (assign, nonatomic) BOOL              muteAll;
@property (assign, nonatomic) BOOL              f1Active;                   // ################### REMOVE
@property (assign, nonatomic) BOOL              f2Active;                   // ################### REMOVE
@property (assign, nonatomic) BOOL              f3Active;                   // ################### REMOVE
@property (strong, nonatomic) NSMutableArray   *history;
@property (readonly)          BOOL              connected;
@property (readonly)          UIImage          *photo;

@property (strong, nonatomic) NSMutableArray   *sensors;

- (APBLESensor *)getSensorType:(APSensorType)type;
- (APBLESensor *)createSensorType:(APSensorType)type;
- (void)removeSensorType:(APSensorType)type;
- (BOOL)hasSensorType:(APSensorType)type;
- (BOOL)isMutedSensorType:(APSensorType)type;
- (void)setMute:(BOOL)mute forSensorType:(APSensorType)type;
- (void)setTriggerDelay:(NSTimeInterval)delay forSensorType:(APSensorType)type;
- (NSTimeInterval)triggerDelayForSensorType:(APSensorType)type;


- (NSArray *)propertyListString;
- (void)checkProximity;
- (void)rssiToPercent;
- (UIImage *)rssiIndicator;
- (UIImage *)batteryIndicator;
- (void)clearServicesAndCharacteristics;

- (void)createHistoryEntryForSensor:(APBLESensor *)sensor;
- (void)closeHistoryEntryForSensor:(APBLESensor *)sensor;
- (NSArray *)historyItemsForSensorType:(APSensorType)sensorType;

@property (readonly)          NSString         *temperature;
@property (readonly)          float             temperatureVal;
@property (assign, nonatomic) BOOL              tempInCelsius;


// ==============================================================================
// -- Class Methods
// ==============================================================================
+ (APBLEDevice *)deviceFromPropertyListString:(NSString *)string;
+ (NSArray *)devicesArrayFromPropertyListArray:(NSArray *)propertyListArray;
+ (NSArray *)propertyListArrayFromDevicesArray:(NSArray *)devicesArray;
+ (NSArray *)getSmsEnabledDevices;
@end
