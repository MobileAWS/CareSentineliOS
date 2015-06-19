//
//  APBLEInterface.h
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 4/3/13.
//  Copyright (c) 2013 AppPotential, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "APBLEDevice.h"
#import "DeviceUIDelegate.h"
#import "AlertInputAcceptedDelegate.h"

enum {
    APDeviceWarningNone       = 0,
    APDeviceWarningBatteryLow = 1,
    APDeviceWarningOutOfRange = 2
} typedef APDeviceWarning;

enum {
    APDeviceContactTrigger   = 0,
    APDeviceContactFunction1 = 1
} typedef APDeviceContact;

////@class APBLEDevice;

@protocol APBLEInterfaceDelegate <NSObject>
- (void)connectedDevice:(APBLEDevice *)device;
- (void)deviceCountChangedTo:(int)deviceCount;
- (void)triggeredSensor:(APBLESensor *)sensor;
- (void)clearedSensor:(APBLESensor *)sensor;
@optional
- (void)disconnectedDevice:(APBLEDevice *)device;
- (void)batteryStateAvailableForDevice:(APBLEDevice *)device;
- (void)rssiUpdatedForDevice:(APBLEDevice *)device;
@end

@interface APBLEInterface : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate,AlertInputAcceptedDelegate>
@property (assign, nonatomic) id <APBLEInterfaceDelegate>   delegate;
@property (strong, nonatomic) NSMutableArray               *registeredArray;    // -- Devices that are registered.
@property (strong, nonatomic) NSMutableArray               *ignoredArray;       // -- Devices that are being ignored.
@property (strong, nonatomic) NSMutableArray               *activeDevices;      // -- Devices that are actively connected.
@property (strong, nonatomic) NSMutableArray               *inactiveDevices;    // -- Devices that are registered but not connected.
@property (weak,nonatomic) id<DeviceUIDelegate> uiDelegate;

- (void)scanForDevices;
- (void)removeRegisteredDevice:(APBLEDevice *)device;
- (void)removeIgnoredDevice:(APBLEDevice *)device;

- (BOOL)devicesWithlowBatteryLevel;
- (BOOL)devicesOutOfRange;
+ (int)batteryPercentUsingCharacteristic:(CBCharacteristic *)characteristic;
+ (float)temperatureForDevice:(APBLEDevice *)device UsingCharacteristic:(CBCharacteristic *)characteristic;
@end
