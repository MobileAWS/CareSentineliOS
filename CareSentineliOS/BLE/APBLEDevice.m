//
//  APBLEDevice.m
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 4/5/13.
//  Copyright (c) 2013 AppPotential, LLC. All rights reserved.
//

#import "APBLEDevice.h"
#import "APBLEInterface.h"
#import "Constants.h"
#import "APAppServices.h"

@interface APBLEDevice ()
@property(strong, nonatomic) NSTimer            *deviceCheckTimer;
@property(strong, nonatomic) CBCharacteristic   *batteryCharateristic;
@property(strong, nonatomic) CBCharacteristic   *thermoCharacteristic;
@end

@implementation APBLEDevice
// ------------------------------------------------------------------------------
#pragma mark - Class Lifecycle
// ------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        _peripheral                 = nil;
        _switchService              = nil;
        _identifier                 = nil;
        _type                       = 0;
        _typeString                 = @"Unknown";
        _name                       = nil;
        _model                      = nil;
        _serialNumber               = nil;
        _firmwareRevision           = nil;
        _hardwareRevision           = nil;
        _manufacturer               = nil;
        _batteryCharateristic       = nil;
        _thermoCharacteristic       = nil;
        _signalPercent              = -1;     // -- Unknown.
        _triggered                  = NO;
        _muteAll                    = NO;
        _f1Active                   = NO;
        _f2Active                   = NO;
        _f3Active                   = NO;
////        _sensors                    = nil;
    }
    
    return self;
}

- (void)dealloc {
    [_deviceCheckTimer invalidate];
    _peripheral                 = nil;
    _switchService              = nil;
    _identifier                 = nil;
    _typeString                 = nil;
    _name                       = nil;
    _model                      = nil;
    _serialNumber               = nil;
    _firmwareRevision           = nil;
    _hardwareRevision           = nil;
    _manufacturer               = nil;
    _batteryCharateristic       = nil;
    _thermoCharacteristic       = nil;
    _deviceCheckTimer           = nil;
    _history                    = nil;
////    _sensors                    = nil;
    
    APLogDealloc;
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    
    BOOL isConnected = NO;
    if ([APAppServices osVersion] >= 7.0f) {
        if (peripheral.state == CBPeripheralStateConnected OR peripheral.state == CBPeripheralStateConnecting) {
            isConnected = YES;
        }
    } else {
#ifndef __IPHONE_7_0
        isConnected = peripheral.isConnected;
#endif
    }
#ifdef RC_PROXIMITY_CHECK
    if (isConnected) {
        // -- Start checking the RSSI
        _deviceCheckTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalProximityCheck target:self selector:@selector(checkProximity) userInfo:nil repeats:YES];
    } else {
        // -- Stop checking the RSSI
        [_deviceCheckTimer invalidate];
        _deviceCheckTimer = nil;
    }
#endif
}

// ------------------------------------------------------------------------------
#pragma mark - Private Methods
// ------------------------------------------------------------------------------
- (void)checkProximity {
    if ([APAppServices osVersion] >= 7.0f) {
        if (_peripheral.state == CBPeripheralStateConnected OR _peripheral.state == CBPeripheralStateConnecting) {
            [self.peripheral readRSSI];
        }
    } else {
#ifndef __IPHONE_7_0
        if (self.peripheral.isConnected) {
            [self.peripheral readRSSI];
        }
#endif
    }
}

// ------------------------------------------------------------------------------
#pragma mark - Public Methods
// ------------------------------------------------------------------------------

- (NSString *)UUIDString {
    return self.identifier.UUIDString;
}

- (NSString *)propertyListString {
    NSString *muteTriggerStringValue = @"N";
    if (self.muteAll)
        muteTriggerStringValue = @"Y";
    
    BOOL hasBedSensor       = [self hasSensorType:APSensorTypeBed];
    BOOL hasChairSensor     = [self hasSensorType:APSensorTypeChair];
    BOOL hasToiletSensor    = [self hasSensorType:APSensorTypeToilet];
    BOOL hasDampnessSensor  = [self hasSensorType:APSensorTypeDampness];
    BOOL hasCallSensor      = [self hasSensorType:APSensorTypeCall];
    BOOL hasPortalSensor    = [self hasSensorType:APSensorTypePortal];
    
    NSTimeInterval  bedAlertDelay      = [self triggerDelayForSensorType:APSensorTypeBed];
    NSTimeInterval  chairAlertDelay    = [self triggerDelayForSensorType:APSensorTypeChair];
    NSTimeInterval  toiletAlertDelay   = [self triggerDelayForSensorType:APSensorTypeToilet];
    NSTimeInterval  dampnessAlertDelay = [self triggerDelayForSensorType:APSensorTypeDampness];
    NSTimeInterval  callAlertDelay     = [self triggerDelayForSensorType:APSensorTypeCall];
    NSTimeInterval  portalAlertDelay   = [self triggerDelayForSensorType:APSensorTypePortal];
    
    BOOL muteBedSensor      = [self isMutedSensorType:APSensorTypeBed];
    BOOL muteChairSensor    = [self isMutedSensorType:APSensorTypeChair];
    BOOL muteToiletSensor   = [self isMutedSensorType:APSensorTypeToilet];
    BOOL muteDampnessSensor = [self isMutedSensorType:APSensorTypeDampness];
    BOOL muteCallSensor     = NO;
    BOOL mutePortalSensor   = [self isMutedSensorType:APSensorTypePortal];
    
    NSString *sensorString   = [NSString stringWithFormat:@"%d,%f,%d\n%d,%f,%d\n%d,%f,%d\n%d,%f,%d\n%d,%f,%d\n%d,%f,%d\n",
                                hasBedSensor, bedAlertDelay, muteBedSensor,
                                hasChairSensor, chairAlertDelay, muteChairSensor,
                                hasToiletSensor, toiletAlertDelay, muteToiletSensor,
                                hasDampnessSensor, dampnessAlertDelay, muteDampnessSensor,
                                hasCallSensor, callAlertDelay, muteCallSensor,
                                hasPortalSensor, portalAlertDelay, mutePortalSensor];
    
    NSString *propertyString = [NSString stringWithFormat:@"%@\n%@\n%d\n%@\n%@\n%@\n%@", [self UUIDString], _serialNumber, _type, _typeString, _name, muteTriggerStringValue, sensorString];
////NSLog(@"--->propertyListString: {{%@}}", propertyString);
    return propertyString;
}

- (BOOL)batteryLow {
    if (!self.batteryService OR !self.connected) return NO;        // -- No service or connection, have to assume battery level is OK.
    
    NSInteger batteryPercentValue = [self batteryPercent];
    
    if (batteryPercentValue <= kThresholdLowBatteryLEvel)    // -- -1 value indicates error reading value
        return YES;
    
    return NO;
}

- (int)batteryPercent {
    if (self.connected AND self.batteryService) {
        if (!_batteryCharateristic) {
            for (CBCharacteristic *characteristic in self.batteryService.characteristics) {
                if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDBatteryData]]) {
                    _batteryCharateristic = characteristic;
                }
            }
        }
        
        if (_batteryCharateristic) {
            [self.peripheral readValueForCharacteristic:_batteryCharateristic];
            return [APBLEInterface batteryPercentUsingCharacteristic:_batteryCharateristic];
        }
    }
    
    return -1;  // -- ERROR!
}

- (void)rssiToPercent {
    NSInteger rssi = self.RSSI;
    
    int estPercent = 0;
    
    // --  Estimate the signal strength as a pct of max
    if (rssi < -97)
        estPercent = 5;
    else if (rssi < -92)
        estPercent = 10;
    else if (rssi < -82)
        estPercent = 25;
    else if (rssi < -75)
        estPercent = 50;
    else if (rssi < -70)
        estPercent = 75;
    else if (rssi < -60)
        estPercent = 90;
    else if (rssi < -44)
        estPercent = 100;
    else
        estPercent = 100;
    
    self.signalPercent = estPercent;
}

- (UIImage *)batteryIndicator {
    if (!self.connected OR !self.batteryService) return nil;
    
    // -- Determine the battery level and display.
    NSInteger batteryPct = self.batteryPercent;
    
    UIImage *image = nil;
    if (batteryPct > 0) {
        if (batteryPct < 15) {
            image = [UIImage imageNamed:kImageBattery1];
        } else if (batteryPct >= 15 AND batteryPct <= 30) {
            image = [UIImage imageNamed:kImageBattery2];
        } else if (batteryPct >= 31 AND batteryPct <= 50) {
            image = [UIImage imageNamed:kImageBattery3];
        } else if (batteryPct >= 51 AND batteryPct <= 75) {
            image = [UIImage imageNamed:kImageBattery4];
        } else if (batteryPct >= 76) {
            image = [UIImage imageNamed:kImageBattery5];
        }
    }
    return image;
}

- (UIImage *)rssiIndicator {
    if (!self.connected) return nil;
    
    // -- Set the connection image
    NSInteger signalPct = self.signalPercent;
    
    UIImage *image = nil;
    
    if (signalPct <= 0) {    // -- Handle special case where RSSI has not bee reread after discovery.
        [self rssiToPercent];
        signalPct = self.signalPercent;
    }
    
    if (signalPct > 0) {
        if (signalPct < 15) {
            image = [UIImage imageNamed:kImageDeviceConnected1];
        } else if (signalPct >= 15 AND signalPct <= 30) {
            image = [UIImage imageNamed:kImageDeviceConnected2];
        } else if (signalPct >= 31 AND signalPct <= 50) {
            image = [UIImage imageNamed:kImageDeviceConnected3];
        } else if (signalPct >= 51 AND signalPct <= 75) {
            image = [UIImage imageNamed:kImageDeviceConnected4];
        } else if (signalPct >= 76) {
            image = [UIImage imageNamed:kImageDeviceConnected5];
        }
    }
    
    return image;
}

- (UIImage *)photo {
    UIImage  *image     = nil;
    NSString *imageName = [self.model stringByAppendingString:@"-photo"];

    image = [UIImage imageNamed:imageName];
    
    return image;
}

- (float)temperatureVal {
    if (self.connected AND self.thermoService) {
        if (!_thermoCharacteristic) {
            for (CBCharacteristic *characteristic in self.thermoService.characteristics) {
                if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDThermoData]]) {
                    _thermoCharacteristic = characteristic;
                }
            }
        }
        
        if (_thermoCharacteristic) {
            return [APBLEInterface temperatureForDevice:self UsingCharacteristic:_thermoCharacteristic];
        }
    }
    
    return kDeviceInvalidTemp;  // -- ERROR!
}

- (NSString *)temperature {
    if (!self.connected OR !self.thermoService) return @"Not Supported";
    
    NSString *tempValue = nil;

    float fahrenheitVal, celsiusVal;
    if (self.tempInCelsius) {
        celsiusVal = self.temperatureVal;
        fahrenheitVal = (celsiusVal * 1.8) + 32;
    } else {
        fahrenheitVal = self.temperatureVal;
        celsiusVal    = (fahrenheitVal - 32) / 1.8;
    }
    
    tempValue = [NSString stringWithFormat:@"%.0f F / %.1f C", fahrenheitVal, celsiusVal];
    
    return tempValue;
}

- (BOOL)connected {
    BOOL isConnected = NO;
    
    if ([APAppServices osVersion] >= 7.0f) {
        if (self.peripheral.state == CBPeripheralStateConnected OR self.peripheral.state == CBPeripheralStateConnecting) {
            isConnected = YES;
        }
    } else {
#ifndef __IPHONE_7_0
        isConnected = self.peripheral.isConnected;
#endif
    }
    
    return isConnected;
}

- (void)clearServicesAndCharacteristics {
    _batteryService       = nil;
    _switchService        = nil;
    _thermoService        = nil;
    _batteryCharateristic = nil;
    _thermoCharacteristic = nil;
}

// ------------------------------------------------------------------------------
#pragma mark - Class Methods
// ------------------------------------------------------------------------------
+ (void)updateDevice:(APBLEDevice *)device usingLine:(NSString *)line forSensorType:(APSensorType)sensorType {
    if (!line) return;
    
    NSArray *items = [line componentsSeparatedByString:@","];
    
    if (!items OR items.count < 2) {
        return;
    }
    
    NSString *flagString  = [items objectAtIndex:0];
    
    if ([flagString boolValue]) {
        APBLESensor *sensor = [device createSensorType:sensorType];
        
        NSString *delayString = [items objectAtIndex:1];
        NSString *muteString  = [items objectAtIndex:2];
        
        sensor.triggerDelay = [delayString floatValue];
        sensor.muteTrigger  = [muteString boolValue];
    }
}


+ (APBLEDevice *)deviceFromPropertyListString:(NSString *)string {
    if (!string) return nil;
    
    APBLEDevice *theDevice = [[APBLEDevice alloc] init];
    
    __block int lineNumber = 0;
    [string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
////NSLog(@"deviceFromPropertyListString -> line (%d): %@", lineNumber, line);
        switch (lineNumber) {
            case 0:
                theDevice.identifier = [[NSUUID alloc] initWithUUIDString:line];
                break;
                
            case 1:
                theDevice.serialNumber = line;
                break;
                
            case 2:
                theDevice.type = [line intValue];
                break;
                
            case 3:
                theDevice.typeString = line;
                break;
                
            case 4:
                theDevice.name = line;
                break;
                
            case 5:
                if ([line rangeOfString:@"Y"].location != NSNotFound)
                    theDevice.muteAll = YES;
                else
                    theDevice.muteAll = NO;
                break;
                
            case 6:     // -- Bed
                [APBLEDevice updateDevice:theDevice usingLine:line forSensorType:APSensorTypeBed];
                break;
                
            case 7:     // -- Chair
                [APBLEDevice updateDevice:theDevice usingLine:line forSensorType:APSensorTypeChair];
                break;
                                
            case 8:     // -- Toilet
                [APBLEDevice updateDevice:theDevice usingLine:line forSensorType:APSensorTypeToilet];
                break;
                
            case 9:     // -- Dampness
                [APBLEDevice updateDevice:theDevice usingLine:line forSensorType:APSensorTypeDampness];
                break;
                
            case 10:    // -- Call
                [APBLEDevice updateDevice:theDevice usingLine:line forSensorType:APSensorTypeCall];
                break;
                
            case 11:    // -- Portal
                [APBLEDevice updateDevice:theDevice usingLine:line forSensorType:APSensorTypePortal];
                break;
                
            default:
                *stop = YES;
                break;
        }
        lineNumber++;
    }];
    
    return theDevice;
}

+ (NSArray *)devicesArrayFromPropertyListArray:(NSArray *)propertyListArray {
    if (!propertyListArray OR [propertyListArray count] == 0) return nil;
    
    NSMutableArray *devicesArray = [[NSMutableArray alloc] init];
    for (NSString *propertyString in propertyListArray) {
        [devicesArray addObject:[APBLEDevice deviceFromPropertyListString:propertyString]];
    }
    
NSLog(@"CREATING DEVICES ARRAY (for load): %@", devicesArray);
    
    return devicesArray;
}

+ (NSArray *)propertyListArrayFromDevicesArray:(NSArray *)devicesArray {
    if (!devicesArray OR [devicesArray count] == 0) return nil;
    
    NSMutableArray *propertyListArray = [[NSMutableArray alloc] init];
    for (APBLEDevice *device in devicesArray) {
        [propertyListArray addObject:[device propertyListString]];
    }
NSLog(@"CREATING PROPERTY LIST ARRAY (for save): %@", devicesArray);
    return propertyListArray;
}

// ------------------------------------------------------------------------------
#pragma mark - Public Sensor Methods
// ------------------------------------------------------------------------------
- (APBLESensor *)getSensorType:(APSensorType)type{
    if (_sensors) {
        for (APBLESensor *sensor in _sensors) {
            if (sensor.type == type) {
////                NSLog(@"      =====> FOUND SENSOR <=====");
                return sensor;
            }
        }
    }
////    NSLog(@"      =====> ! SENSOR NOT FOND ! <=====");
    return nil;
}

- (APBLESensor *)createSensorType:(APSensorType)type {
    APBLESensor *sensor = nil;
    
    if (!_sensors) {
        _sensors = [[NSMutableArray alloc]init];
    } else {
        // -- Make sure the sensor does not already exist, if it does just return it.
        sensor = [self getSensorType:type];
        if (sensor) {
            return sensor;
        }
    }
    
    if (_sensors) {
        sensor = [[APBLESensor alloc]init];
        
        [_sensors addObject:sensor];
        
        if (sensor) {
            sensor.type         = type;
            sensor.parentDevice = self;
        }
    }
    
    return sensor;
}

- (void)removeSensorType:(APSensorType)type {
    APBLESensor *sensor = [self getSensorType:type];
    if (sensor) {
        [self.sensors removeObject:sensor];
    }
}

- (BOOL)hasSensorType:(APSensorType)type {
    if ([self getSensorType:type]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isMutedSensorType:(APSensorType)type {
    APBLESensor *sensor = [self getSensorType:type];
    
    if (sensor AND sensor.muteTrigger) {
        return YES;
    }
    
    return NO;
}

- (void)setMute:(BOOL)mute forSensorType:(APSensorType)type {
    APBLESensor *sensor = [self getSensorType:type];
    
    if (sensor) {
        sensor.muteTrigger = mute;
    }
}

- (void)setTriggerDelay:(NSTimeInterval)delay forSensorType:(APSensorType)type {
    APBLESensor *sensor = [self getSensorType:type];
    
    if (sensor) {
        sensor.triggerDelay = delay;
    }
}

- (NSTimeInterval)triggerDelayForSensorType:(APSensorType)type {
    APBLESensor *sensor = [self getSensorType:type];
    
    if (sensor) {
        return sensor.triggerDelay;
    }
    
    return 0;
}

// ------------------------------------------------------------------------------
#pragma mark - Public History Methods
// ------------------------------------------------------------------------------
- (void)createHistoryEntryForSensor:(APBLESensor *)sensor {
    if (!_history) {
        _history = [[NSMutableArray alloc]init];
    }
    
    if (_history) {
        sensor.openHistoryEntry             = [[APBLESensorHistoryEntry alloc] init];
        sensor.openHistoryEntry.triggerTime = [NSDate date];
        sensor.openHistoryEntry.sensorType  = sensor.type;
        
        // -- Are we already at max entries?
        if (_history.count >= kHistoryEntriesMaxNumber) {
            // -- Drop the oldest entry.
            [_history removeObjectAtIndex:0];
        }
        [_history addObject:sensor.openHistoryEntry];
    }
}

- (void)closeHistoryEntryForSensor:(APBLESensor *)sensor {
    sensor.openHistoryEntry.clearedTime = [NSDate date];
    if (sensor.type == APSensorTypeCall OR sensor.type == APSensorTypePortal) {
        sensor.openHistoryEntry.reason = APSensorHistoryClearReasonNormal;
    } else {
        sensor.openHistoryEntry.reason = APSensorHistoryClearReasonUserAction;
    }
    sensor.openHistoryEntry = nil;
}

- (NSArray *)historyItemsForSensorType:(APSensorType)sensorType {
    NSMutableArray *items = [[NSMutableArray alloc]init];
    NSArray        *results = nil;
    
    // -- Filter the list based on sensor type.
    for (APBLESensorHistoryEntry *entry in self.history) {
        if (entry.sensorType == sensorType) {
            [items addObject:entry];
        }
    }
    
    // -- Repackage teh results in a standard NSArray.
    if (items.count) {
        results = [NSArray arrayWithArray:items];
    }
    
    return results;
}
@end

// ==============================================================================

@interface APBLESensor ()
/*****
@property(strong, nonatomic) NSTimer            *deviceCheckTimer;
@property(strong, nonatomic) CBCharacteristic   *batteryCharateristic;
@property(strong, nonatomic) CBCharacteristic   *thermoCharacteristic;
 *****/

@property (strong, nonatomic) UIImage            *theImage;
@property (assign, nonatomic) BOOL               _manualClear;
@end

@implementation APBLESensor
static NSArray *s_sensorTypeLabels = nil;

// ------------------------------------------------------------------------------
#pragma mark - Class Methods
// ------------------------------------------------------------------------------
+ (NSArray *)sensorTypeLabels {
    if (!s_sensorTypeLabels) {
        // -- Setup Labels
        s_sensorTypeLabels = [NSArray arrayWithObjects:@"Bed", @"Chair", @"Toilet Seat", @"Incontinence", @"Call Button", @"Portal", nil];
    }
    
    return s_sensorTypeLabels;
}

+ (NSString *)sensorTypeStringForType:(APSensorType)type {
    NSArray *sensorTypeLabels = [APBLESensor sensorTypeLabels];
    
    return [sensorTypeLabels objectAtIndex:type];
}

// ------------------------------------------------------------------------------
#pragma mark - Class Lifecycle
// ------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        
        // -- Load history.
        
        
    }
    
    return self;
}

- (void)dealloc {
    _openHistoryEntry = nil;
    
    APLogDealloc;
}

- (void)setType:(APSensorType)type {
    _type = type;
    
    self.name = [self sensorTypeString];
    
    // -- Load an image.
    NSString *imageName = [NSString stringWithFormat:@"Sensor-%d", type];
    _theImage = [UIImage imageNamed:imageName];
    
    // -- Certain sensors must be manually cleared.
    if (type == APSensorTypeCall OR type == APSensorTypePortal) {
        __manualClear     = YES;
        _clearSoundIndex = -1;
    }
}

- (void)setTriggered:(BOOL)triggered {
    _triggered = triggered;
    
    if (triggered) {
        [_delegate sensorTriggered:self];
        
        // -- Create new history item.
        [_parentDevice createHistoryEntryForSensor:self];
    } else {
        [_delegate sensorCleared:self];
        
        // -- Close outstanding history item.
        [_parentDevice closeHistoryEntryForSensor:self];
    }
}

// ------------------------------------------------------------------------------
#pragma mark - Public Methods
// ------------------------------------------------------------------------------
- (NSString *)sensorTypeString {
    return [APBLESensor sensorTypeStringForType:_type];
}

- (UIImage *)image {
    return _theImage;
}

- (BOOL)manualClear {
    return __manualClear;
}


@end

// ==============================================================================
@interface APBLESensorHistoryEntry ()

@end

@implementation APBLESensorHistoryEntry

@end