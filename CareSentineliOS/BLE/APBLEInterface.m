//
//  APBLEInterface.m
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 4/3/13.
//  Copyright (c) 2013 AppPotential, LLC. All rights reserved.
//

#import "APBLEInterface.h"
#import "APBLEDevice.h"
#import "APSettings.h"
#import "Constants.h"
#import "APAppServices.h"
#import "AppDelegate.h"
#import "InputAlertViewDelegate.h"

@interface APBLEInterface (){
    NSMutableArray *pendingInputDelegates;
}
@property (strong, nonatomic) CBCentralManager             *centralManager;
@property (strong, nonatomic) NSMutableArray               *discoveredPeripherals;
@property (strong, nonatomic) NSMutableArray               *pendingNewDevices;
@property (strong, nonatomic) NSArray                      *deviceTypesArray;
@property (strong, nonatomic) NSArray                      *servicesArray;
@property (assign, nonatomic) NSInteger                     lastRssi;

@property (assign, nonatomic) NSInteger                     presentationAttempts;

@property (strong, nonatomic) NSTimer                      *pendingDeviceTimer;
@property (strong, nonatomic) NSTimer                      *retryTimer;
@property (strong, nonatomic) NSTimer                      *watchConnectionStatusTimer;
@property (strong, nonatomic) NSTimer                      *deviceScanTimer;
@property (assign, nonatomic) BOOL                          havePebble;          // #### Probably only need this BOOL for debugging.
@end

#define kMaxNumberPresentationRetries   15
#define kTimeIntervalPresentationCheck  1.0f

@implementation APBLEInterface

static BOOL s_processing_restart = NO;

// ------------------------------------------------------------------------------
#pragma mark - Class Lifecycle
// ------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) { 
        if ([APAppServices osVersion] >= 7.0f) {
            _centralManager      = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey:kNameApp,
                                                                                                        CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES]}];
        } else {
            _centralManager      = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        }
        
        
        _centralManager.delegate = self;
        
        // -- Load an array of supported device types from the PLIST.
        NSString *plistPath      = [[NSBundle mainBundle] pathForResource:kPListBLEDeviceTypes ofType:kPListFileType];
        _deviceTypesArray        = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        // -- Get list of devices already registered with the app by the user.
        _registeredArray         = [NSMutableArray arrayWithArray:[APSettings loadDevicesArray]];
        _ignoredArray            = [NSMutableArray arrayWithArray:[APSettings loadIgnoredArray]];
        
        // -- Array of the services we need.
        _servicesArray           = [NSArray arrayWithObjects:[CBUUID UUIDWithString:kUUIDThermoService],       // ###################### PROTOTYPE ONLY????
                                                             [CBUUID UUIDWithString:kUUIDBatteryService],
                                                             [CBUUID UUIDWithString:kUUIDDeviceInfoService],
                                                             [CBUUID UUIDWithString:kUUIDCareSentinelService],
                                                             nil];
        
        
        _activeDevices           = [[NSMutableArray alloc] init];
        //_inactiveDevices         = [[NSMutableArray alloc] initWithArray:_registeredArray];     // -- At load, all registered devices are inactive in the app.
        _discoveredPeripherals   = [[NSMutableArray alloc] init];
        _pendingNewDevices       = [[NSMutableArray alloc] init];
        pendingInputDelegates = [[NSMutableArray alloc]init];
        
        _retryTimer              = nil;
    }
    return self;
}

- (void)dealloc {
    [_pendingDeviceTimer invalidate];
    [_retryTimer invalidate];
    _centralManager        = nil;
    _discoveredPeripherals = nil;
    _deviceTypesArray      = nil;
    _registeredArray       = nil;
    _ignoredArray          = nil;
    _servicesArray         = nil;
    _activeDevices         = nil;
    _inactiveDevices       = nil;
    _pendingDeviceTimer    = nil;
    _retryTimer            = nil;
    _pendingNewDevices     = nil;
    
    APLogDealloc;
}

- (void)scanForDevicesExpired:(NSTimer *)timer{
    [self.centralManager stopScan];
    [timer invalidate];
    self.deviceScanTimer = nil;
    [AppDelegate hideLoadingMask];
}

- (void)scanForDevices {
    self.deviceScanTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector: @selector(scanForDevicesExpired:) userInfo:nil repeats:false];
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    APLog(@"...Scanning for Devices...");
}

// ------------------------------------------------------------------------------
#pragma mark - CBCentralManager delegate
// ------------------------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            APLog(@"Central updated to state CBCentralManagerStatePoweredOn");
            [self scanForDevices];
            
            if ([APAppServices osVersion] < 7.0f) {
                break;  // -- Get outta town!!!!
            }

            // -- iOS7 Restoration Processing
            for (APBLEDevice *device in self.activeDevices) {
                if (device.peripheral.state == CBPeripheralStateConnected) {    // -- Is the device already connected?
                    // -- Test if the services have already been discovered.
                    NSUInteger serviceIndex = [device.peripheral.services indexOfObjectPassingTest:^BOOL(CBService *service, NSUInteger index, BOOL *stop) {
                        return [service.UUID isEqual:kUUIDCareSentinelService];
                    }];
                    
                    // -- Services not yet discovered, discover them...
                    if (serviceIndex == NSNotFound) {
                        [device.peripheral discoverServices:self.servicesArray];
                        continue;
                    }
                    
                    for (CBService *service in device.peripheral.services) {
                        if ([service.UUID isEqual:kUUIDCareSentinelService]) {
                            // -- Check for Switch Charateristic
                            NSUInteger switchIndex = [service.characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic *characteristic, NSUInteger index, BOOL *stop) {
                                return [characteristic.UUID isEqual:kUUIDCareSentinelChar];
                            }];
                            
                            if (switchIndex == NSNotFound) {
                                [device.peripheral discoverCharacteristics:@[kUUIDCareSentinelChar] forService:service];
                                continue;
                            }
                            
                            CBCharacteristic *switchCharacteristic = service.characteristics[switchIndex];
                            if (!switchCharacteristic.isNotifying) {
                                [device.peripheral setNotifyValue:YES forCharacteristic:switchCharacteristic];
                            }
                        }
                        
                        if ([service.UUID isEqual:kUUIDBatteryService]) {
                            // -- Check for Battery Charateristic
                            NSUInteger batteryIndex = [service.characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic *characteristic, NSUInteger index, BOOL *stop) {
                                return [characteristic.UUID isEqual:kUUIDBatteryData];
                            }];
                            
                            if (batteryIndex == NSNotFound) {
                                [device.peripheral discoverCharacteristics:@[kUUIDBatteryData] forService:service];
                                continue;
                            }
                        }

                        if ([service.UUID isEqual:kUUIDThermoService]) {
                            // -- Check for Thermo Charateristic
                            NSUInteger thermoIndex = [service.characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic *characteristic, NSUInteger index, BOOL *stop) {
                                return [characteristic.UUID isEqual:kUUIDThermoData];
                            }];
                            
                            if (thermoIndex == NSNotFound) {
                                [device.peripheral discoverCharacteristics:@[kUUIDThermoData] forService:service];
                                continue;
                            }
                        }
                    }
                }
            }
 
            break;
            
        case CBCentralManagerStateUnauthorized:
            APLog(@"Central updated to state CBCentralManagerStateUnauthorized");
            break;
            
        case CBCentralManagerStatePoweredOff:
            APLog(@"Central updated to state CBCentralManagerStatePoweredOff");
            break;
            
        case CBCentralManagerStateResetting:
            APLog(@"Central updated to state CBCentralManagerStateResetting");
            break;
            
        case CBCentralManagerStateUnknown:
            APLog(@"Central updated to state CBCentralManagerStateUnknown");
            ////APAlert(@"Remote Trigger Not Configured", @"This system is not able to activate Bluetooth Low Energy connectivity.  Remote triggering will not be enabled.  You can try to restart your iPhone to see if the system can restore connectivity.");
            break;
        
        case CBCentralManagerStateUnsupported:
        default:
            APLog(@"BLE Not Supported");
            break;
    }
}

// ########## iOS7: State restoration for app by iOS when app is restarted to process and event
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    // -- Called by iOS7 when app restarted to handle BLE event
    s_processing_restart = YES;
    
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    for (CBPeripheral *peripheral in peripherals) {
        APLog(@">>>> iOS7 Restoring State for Peripheral: %@ <<<<", peripheral.name);
        
        peripheral.delegate     = self;
        [peripheral discoverServices:_servicesArray];
        
        APDeviceType deviceType = [self deviceType:peripheral.name];
        
        // -- Prepare the new device for services discovery.
        APBLEDevice *device     = [[APBLEDevice alloc] init];
        device.peripheral       = peripheral;
        
        device.identifier       = peripheral.identifier;

        _lastRssi               = [peripheral.RSSI integerValue];
        device.RSSI             = _lastRssi;
        device.type             = deviceType;
        
        device.typeString       = peripheral.name;             // -- Default using the name.
        device.name             = peripheral.name;
        device.muteAll          = NO;
        
        // -- Need to add to active devices?
        BOOL notInList = YES;
        
        for (APBLEDevice *device in _activeDevices) {
            if ([peripheral.identifier isEqual:device.identifier]) {
                notInList = NO;
                break;
            }
        }
        
        if (notInList) {
            // -- Only add if not already in the list.
            [_activeDevices addObject:device];
        }
        
        notInList = YES;
    }
}


- (APDeviceType)deviceType:(NSString *)typeName {
    // -- Returns 0 if no match
    
    // -- Check's array of device types loaded from PLIST to see if the specified device type is supported.
    NSInteger    index       = 0;
    APDeviceType matchedType = 0;
    for (NSString *type in _deviceTypesArray) {
        // -- Wildcard in Device Type?
        NSRange matchRange = [type rangeOfString:@"*"];
        if (matchRange.location == NSNotFound) {        // -- No wildcard, exact match...
            if ([type isEqualToString:typeName]) {
                matchedType = (APDeviceType)(index + 1);
                break;
            }
        } else {                                // -- Partial match up to wildcard character.
            NSString *matchString = [type substringToIndex:matchRange.location];
            
            matchRange = [typeName rangeOfString:matchString];
            if (matchRange.location != NSNotFound) {
                matchedType = (APDeviceType)(index + 1);
                break;
            }
        }

        index++;
    }
    
    return matchedType;
}

-(void)declinedWithObject:(id)target{
    [pendingInputDelegates removeObject:target];
    NSDictionary *values = (NSDictionary *)((InputAlertViewDelegate *)target).targetObject;
    CBPeripheral *peripheral = (CBPeripheral *)[values objectForKey:@"peripheral"];
    [_pendingNewDevices removeObject:[values objectForKey:@"peripheral"]];
    [self->_uiDelegate deviceIgnored:peripheral];

}

-(void) input:(NSString *)input AcceptedWithObject:(id)target{

    [pendingInputDelegates removeObject:target];
    NSDictionary *values = (NSDictionary *)((InputAlertViewDelegate *)target).targetObject;
    CBPeripheral *peripheral = (CBPeripheral *)[values objectForKey:@"peripheral"];
    CBCentralManager *central = (CBCentralManager *)[values objectForKey:@"central"];
    [_pendingNewDevices removeObject:[values objectForKey:@"peripheral"]];
    
    [self->_uiDelegate deviceDiscovered:peripheral withName:input];
    
    if (![_discoveredPeripherals containsObject:peripheral]){
        [_discoveredPeripherals addObject:peripheral];
        APLog(@"FOUND >>>>>>>>> %@   with RSSI: %ld", peripheral.name, (long)_lastRssi);   // ######################
        // -- Don't attempt to connect ignored devices.
        APBLEDevice *ignoredDevice = [self findIgnoredDeviceUsingPeripheral:peripheral];
        if (ignoredDevice) {
            APLog(@"Found Device Being Ignored (S/N: %@)", ignoredDevice.serialNumber);     // ######################
            return;
        }
        if ([APAppServices osVersion] >= 7.0f) {
            if (peripheral.state != CBPeripheralStateConnected AND peripheral.state != CBPeripheralStateConnecting) {
                [central connectPeripheral:peripheral options:nil];
            }
        } else {
#ifndef __IPHONE_7_0
            if (!peripheral.isConnected) {
                [central connectPeripheral:peripheral options:nil];
            }
#endif
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    APLog(@"didDiscoverPeripheral: %@ (%3.2fdB)\n--------------------\n%@\n--------------------", peripheral.name, RSSI.floatValue, advertisementData);
    

    if ([_pendingNewDevices containsObject:peripheral]){
        return;
    }
    
    
    Device *device = [self->_uiDelegate deviceForUDID:peripheral.identifier.UUIDString];
    
    if ([device isIgnored]){
        return;
    }
    
    if (device != nil){
        if (peripheral.state != CBPeripheralStateConnected AND peripheral.state != CBPeripheralStateConnecting) {
            [_discoveredPeripherals addObject:peripheral];
            [central connectPeripheral:peripheral options:nil];
        }
        return;
    }

        
    // -- Reject if signal is too weak.
    if (RSSI.integerValue > -32) {
        NSLog(@"Rejected peripheral because RSSI is too weak.");
        return;
    }
    
    APDeviceType deviceType = [self deviceType:peripheral.name];
    if (!deviceType) {  // -- Can support multiple device types as define in PLIST
        APLog(@"Unsupported Device Ignored: %@.", peripheral.name);     // ######################
        return;
    }
    
    // -- Due to an iOS6 bug (security update?) need to connect to peripheral before accessing the UUID.  Will be nil on first time connection to the phone (acording to TI Sensor tag sample app).
    peripheral.delegate   = self;

    _lastRssi = [RSSI integerValue];
    
    
    InputAlertViewDelegate *inputDelegate = [[InputAlertViewDelegate alloc]init];
    inputDelegate.delegate = self;
    inputDelegate.targetObject = @{@"peripheral":peripheral,@"central":central};
    [pendingInputDelegates addObject:inputDelegate];
    
    [_pendingNewDevices addObject:peripheral];

    [AppDelegate showInputWith:@"Enter A Description (e.g Jacket Activator) & tap Use It. If the device is not yours tap Not Mine to ignore." title:@"New Monitor Device" defaultText:peripheral.name delegate:inputDelegate];

}

- (void)connectDevice:(APBLEDevice *)registeredDevice {
    [_activeDevices addObject:registeredDevice];
    
    // -- Update the trigger monitoring status using last setting.
    for (APBLEDevice *device in _registeredArray) {
        if ([registeredDevice.identifier isEqual:device.identifier]) {
            registeredDevice.muteAll = device.muteAll;
        }
    }
    
    for (APBLEDevice *device in _inactiveDevices) {
        if ([device.UUIDString isEqual:registeredDevice.UUIDString]) {
            [_inactiveDevices removeObject:device];
            break;
        }
    }
    
    [_delegate connectedDevice:registeredDevice];
    
    [_delegate deviceCountChangedTo:(int)_activeDevices.count];
    
    APLog(@"CONNECTION COMPLETE: '%@'", registeredDevice.peripheral.name);   // ######################
    
    [registeredDevice checkProximity];      // -- Get initial RSSI value.
    [self->_uiDelegate deviceConnected:registeredDevice.peripheral phsyicalDevice:registeredDevice];
}

- (void)showAddControllerForPendingNewDevice {
    APBLEDevice *device = [_pendingNewDevices objectAtIndex:0];
    
    if (_retryTimer) {  // -- Detect if this is a retry attempt and handle properly.
        if (!device.serialNumber) {
            APLog(@"Retry Attempt: %ld", (long)_presentationAttempts);     // ######################
            
            if (_presentationAttempts >= kMaxNumberPresentationRetries) {
                [_retryTimer invalidate];
                _retryTimer = nil;
                _presentationAttempts = 0;
                NSLog(@"Discovery has timed out for device: %@.  Device may have disconnected.", device.name);
            } else {
                _presentationAttempts++;
            }
            
            return;
        } else {
            [_retryTimer invalidate];   // -- Got the information!
            _retryTimer = nil;
        }
    }
    [_pendingNewDevices removeObject:device];   // -- Remove the device from the pending queue.
}

- (void)addPendingNewDevice {
    APBLEDevice *device = [_pendingNewDevices objectAtIndex:0];
    
    if (device.serialNumber) {      // -- Make sure the device is connected and details are discovered and loaded.
        [self showAddControllerForPendingNewDevice];
    } else {
        _presentationAttempts = 1;
        _retryTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalPresentationCheck target:self selector:@selector(showAddControllerForPendingNewDevice) userInfo:nil repeats:YES];
        APLog(@"Starting Retries...");      // ######################
    }
}

- (void)checkForNewDevice {
    if (_pendingNewDevices.count) { // -- Do we have pending devices?
        [self addPendingNewDevice];
    } else {
        [_pendingDeviceTimer invalidate];
        _pendingDeviceTimer = nil;
    }
}

- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    if ([APAppServices osVersion] >= 7.0f) {
        if (!peripheral OR peripheral.state != CBPeripheralStateConnected OR peripheral.state != CBPeripheralStateConnecting) {
            return;
        }
    } else {
#ifndef __IPHONE_7_0
        if (!peripheral OR !peripheral.isConnected) {
            return;
        }
#endif
    }
    
    // -- Look through services to find notifications.
    if (peripheral.services) {
        for (CBService *service in peripheral.services) {
            if (service.characteristics) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    // -- See if we have any notifications we're subscribed to...
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kUUIDCareSentinelChar]]) {
                        if (characteristic.isNotifying) {
                            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // -- Cancel the peripheral connection
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral readRSSI];
    APLog(@"connected peripheral %@",peripheral.name);

    APLog(@"didConnectPeripheral: %@, discovering services...", peripheral.name);        // ######################
//NSLog(@"* * * * * * * * didConnectPeripheral: %@, discovering services...", peripheral.name);        // ######################
    APDeviceType deviceType = [self deviceType:peripheral.name];
////APLog(@"--------------> Device Type: %d", deviceType);  // ######################
    if (deviceType) {  // -- Can support multiple device types as define in PLIST
        peripheral.delegate           = self;
        APBLEDevice *registeredDevice = nil;
   NSLog(@"------> PROCESSING CONNECTION TO PERIPHERAL: %@", peripheral.name);
        // -- Already connected?  Stop processing.
        for (APBLEDevice *device in _activeDevices) {
            if ([peripheral.identifier isEqual:device.identifier]) {
                return;
            }
        }
        
        // -- Is this in our ignore list?
        for (APBLEDevice *device in _ignoredArray) {
            if ([peripheral.identifier isEqual:device.identifier]) {
                [_centralManager cancelPeripheralConnection:peripheral];
                return;     // -- Ignore it.
            }
        }
        
        // -- Is this already registered with the App?
        for (APBLEDevice *device in _registeredArray) {
            if ([peripheral.identifier isEqual:device.identifier]) {
                registeredDevice            = device;
                registeredDevice.peripheral = peripheral;
                [peripheral discoverServices:_servicesArray];
                break;
            }
        }
        
        if (!registeredDevice) {
            
            // -- Prepare the new device for services discovery.
            registeredDevice             = [[APBLEDevice alloc] init];
            registeredDevice.peripheral  = peripheral;
            registeredDevice.identifier  = peripheral.identifier;
            registeredDevice.RSSI        = _lastRssi;
            APLog(@"2. ADDING INIT RSSI: %ld to DEVICE: %@", (long)registeredDevice.RSSI, registeredDevice);        // ######################
            registeredDevice.type        = deviceType;

            registeredDevice.typeString  = peripheral.name;             // -- Default the name.
            registeredDevice.name        = peripheral.name;
            registeredDevice.muteAll     = YES;                         // -- Make sure we ignore the device until it's accepted as a valid device by the user.

            [self->_registeredArray addObject:registeredDevice];
            /*
            [_pendingNewDevices addObject:registeredDevice];
            if (!_pendingDeviceTimer) {
                _pendingDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeIntervalPresentationCheck target:self selector:@selector(checkForNewDevice) userInfo:nil repeats:YES];
            }
             */
            
            [self connectDevice:registeredDevice];
            [peripheral discoverServices:_servicesArray];
        } else {
            registeredDevice.RSSI = _lastRssi;
            APLog(@"1. ADDING INIT RSSI: %ld to DEVICE: %@", (long)registeredDevice.RSSI, registeredDevice);        // ######################
            [self connectDevice:registeredDevice];
        }
    } else {        // -- Device not supported.
        [self cancelPeripheralConnection:peripheral];
    }
    
    // -- Remove peripheral from discovered list.
    [self removeDiscoveredPeripheral:peripheral];
}

- (APBLEDevice *)findIgnoredDeviceUsingPeripheral:(CBPeripheral *)peripheral {
    if (!peripheral OR !peripheral.identifier) return nil;
    
    for (APBLEDevice *device in _ignoredArray) {
        if ([device.identifier isEqual:peripheral.identifier]) {
            return device;
        }
    }
    
    return nil;
}

- (NSInteger)findDiscoveredPeripheral:(CBPeripheral *)peripheral {
    NSInteger index = 0;
    for (CBPeripheral *listPeriph in _discoveredPeripherals) {
        if ([listPeriph isEqual:peripheral]){
            return index;
        } else {
            index++;
        }
    }

    return NSNotFound;
}

- (void)removeDiscoveredPeripheral:(CBPeripheral *)peripheral {
    NSInteger index = [self findDiscoveredPeripheral:peripheral];
    if (index != NSNotFound) {
        [_discoveredPeripherals removeObjectAtIndex:index];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {    
    APLog(@"DISCONNECTED: '%@'", peripheral.name);    // ######################
    if (error) {
        NSLog(@"DISCONNECTED WITH ERROR: %@", error.description);
    }

    APBLEDevice *disconnectedDevice = nil;
    
    BOOL wasActiveDevice = NO;
    
    for (APBLEDevice *device in _activeDevices) {
        if ([peripheral.identifier isEqual:device.identifier]) {
            disconnectedDevice = device;
            
            [central stopScan];
            
            // -- Remove the device from the active list.
            [_activeDevices removeObject:device];
            
            wasActiveDevice = YES;
            [self.uiDelegate disconnectDevice:peripheral];
            break;
        }
    }
    
    // -- If not an active device, check the pending devices.
    if (!wasActiveDevice) {
        for (APBLEDevice *device in _pendingNewDevices) {
            if ([peripheral.identifier isEqual:device.identifier]) {
                disconnectedDevice = device;
                
                [central stopScan];
                
                // -- Remove the device from the pending list.
                [_pendingNewDevices removeObject:device];
                
                break;
            }
        }
    }

    if (disconnectedDevice) {
        [central stopScan];
        
        disconnectedDevice.peripheral = nil;
        disconnectedDevice.triggered  = NO;
        [disconnectedDevice clearServicesAndCharacteristics];
        
        // -- Remove peripheral from discovered list.
        [self removeDiscoveredPeripheral:disconnectedDevice.peripheral];
        
        [_activeDevices removeObject:disconnectedDevice];
        [_inactiveDevices addObject:disconnectedDevice];
        
        if ([_delegate respondsToSelector:@selector(disconnectedDevice:)])
            [_delegate disconnectedDevice:disconnectedDevice];
        
        if ([_delegate respondsToSelector:@selector(deviceCountChangedTo:)])
            [_delegate deviceCountChangedTo:(int)_activeDevices.count];
        
        [self scanForDevices];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@ Failed Connection for: '%@'", error.description, peripheral.name);
    
    [self cancelPeripheralConnection:peripheral];
}

// ------------------------------------------------------------------------------
#pragma mark - CBPeripheral delegate
// ------------------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    APLog(@"discovered peripheral %@",peripheral.name);
    if (error != nil) {
		APLogErrMsg(@"%@ for Periperal: '%@'", error, peripheral.name);
        [self cancelPeripheralConnection:peripheral];
		return ;
	}
    
    APBLEDevice *workingDevice = [self deviceForPeripheral:peripheral];

    if (!workingDevice) return;     // -- Ignore if not from registered active device.

    NSArray *characteristics = nil;
    for (CBService *s in peripheral.services) {
        switch (workingDevice.type) {
            case APDeviceTypeCareSentinel:
                if ([s.UUID isEqual:[CBUUID UUIDWithString:kUUIDThermoService]])  {
////                    APLog(@"Found Thermo Service: service UUID = %@", s.UUID);
                    workingDevice.thermoService = s;
                    [peripheral discoverCharacteristics:characteristics forService:s];
                } else if ([s.UUID isEqual:[CBUUID UUIDWithString:kUUIDBatteryService]])  {
////                    APLog(@"Found Battery Status Service: service UUID = %@", s.UUID);
                    workingDevice.batteryService = s;
                    [peripheral discoverCharacteristics:characteristics forService:s];
                } else if ([s.UUID isEqual:[CBUUID UUIDWithString:kUUIDCareSentinelService]])  {
////                    APLog(@"Found Switch Service: service UUID = %@", s.UUID);
                    workingDevice.switchService = s;
                    [peripheral discoverCharacteristics:characteristics forService:s];
                } else if ([s.UUID isEqual:[CBUUID UUIDWithString:kUUIDDeviceInfoService]])  {
////                    APLog(@"Found Device Info Service: service UUID = %@", s.UUID);
                    [peripheral discoverCharacteristics:characteristics forService:s];
                }
                
                break;
                
            default:
                APLogErrMsg(@"discovered service for unmapped device %@", [s UUID]);     // -- Should never get here.
                break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error != nil) {
		APLogErrMsg(@"%@ for service: %@\n", error.description, service.UUID);
        [self cancelPeripheralConnection:peripheral];
		return ;
	}

    APBLEDevice *workingDevice = [self deviceForPeripheral:peripheral];
    
    if (!workingDevice) return;     // -- Ignore if not from registered active device.
    
	NSArray *characteristics = [service characteristics];

    CBCharacteristic *characteristic;
    
	for (characteristic in characteristics) {
        switch (workingDevice.type) {
            case APDeviceTypeCareSentinel:
                if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDBatteryData]]) {
////                    NSLog(@"Discovered Battery Characteristic");
                    [peripheral readValueForCharacteristic:characteristic];
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    if ([_delegate respondsToSelector:@selector(batteryStateAvailableForDevice:)])
                        [_delegate batteryStateAvailableForDevice:workingDevice];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDThermoData]]) {
////                    APLog(@"Discovered Thermometer Characteristic (%@) (%@)", [characteristic UUID], kUUIDThermoData);
////                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    [peripheral readValueForCharacteristic:characteristic];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDCareSentinelChar]]) {
////                    APLog(@"Discovered Switch Characteristic");
                    [peripheral readValueForCharacteristic:characteristic];
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDSerialNumber]]) {
////                    APLog(@"Discovered Serial Number Characteristic");
                    [peripheral readValueForCharacteristic:characteristic];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDModelNumber]]) {
////                    APLog(@"Discovered Model Number Characteristic");
                    [peripheral readValueForCharacteristic:characteristic];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDFirmwareRevision]]) {
////                    APLog(@"Discovered Firmware Rev Characteristic");
                    [peripheral readValueForCharacteristic:characteristic];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDHardwareRevision]]) {
////                    APLog(@"Discovered Hardware Rev Characteristic");
                    [peripheral readValueForCharacteristic:characteristic];
                } else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDManufacturer]]) {
                    [peripheral readValueForCharacteristic:characteristic];
                }

                
                break;
                
            default:
                APLogErrMsg(@"Discovered unmapped characteristic %@", [characteristic UUID]);     // -- Should never get here.
                break;
        }
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        APLogErrMsg(@"%@ for Characteristic %@", error, characteristic.UUID);
        return;
    }

    APLog(@"Now receiving notification for %@",characteristic.UUID);
    [AppDelegate hideLoadingMask];

    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        APLogErrMsg(@"%@ for Characteristic %@", error, characteristic.UUID);
    }
}

- (APBLEDevice *)deviceForPeripheral:(CBPeripheral *)peripheral {
    APBLEDevice *workingDevice = nil;
    for (APBLEDevice *device in _activeDevices) {
        if ([device.peripheral isEqual:peripheral]) {
            workingDevice = device;
            break;
        }
    }
    
    // -- Doesn't match active devices, then assume this is reference to the most recently discovered device.
    if (!workingDevice) {
        // -- Scan through pending new devices.
        for (APBLEDevice *device in _pendingNewDevices) {
            if ([device.peripheral isEqual:peripheral]) {
                workingDevice = device;
                break;
            }
        }
    }
    
    return workingDevice;
}

- (void)processSensorType:(APSensorType)sensorType forSensor:(APBLEDevice *)workingDevice withValue:(uint16_t)value {
    APBLESensor *sensor = [workingDevice getSensorType:APSensorTypeBed];
    
    if (value & !sensor.triggered) {
        if (sensor.triggerDelay == 0) {
            // -- Triggered
            [_delegate triggeredSensor:sensor];
        } else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, sensor.triggerDelay * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // -- Make sure the sensor is still tirggered afte the delay.
                if (sensor.triggered) {
                    [_delegate triggeredSensor:sensor];
                }
            });
        }
    } else if (value AND sensor.triggered) {
        // -- Cleared
        [_delegate clearedSensor:sensor];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error != nil) {
        APLogErrMsg(@"%@ for Characteristic %@", error, characteristic.UUID);
		return ;
	}
    
    APBLEDevice *workingDevice = [self deviceForPeripheral:peripheral];
    
    NSData *data = characteristic.value;
        
    // -- Serial Number
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDBatteryData]]) {
        if (data.length > 0) {
            workingDevice.batteryPercent = [APBLEInterface batteryPercentUsingCharacteristic:characteristic];
            [self->_uiDelegate didUpdateDevice:peripheral];
            NSLog(@"-----------------Battery updated!,%d",workingDevice.batteryPercent);
        }
        return;
    }
    
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDSerialNumber]]) {
        if (data.length > 0) {
            workingDevice.serialNumber = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [self->_uiDelegate didUpdateHwIdForDevice:peripheral];
////            APLog(@"--- S/N VALUE ---> %@", workingDevice.serialNumber);
        }

        return;
    }
    
    // -- Model
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDModelNumber]]) {
        if (data.length > 0) {
            workingDevice.model = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
////            APLog(@"--- MODEL VALUE ---> %@", workingDevice.model);
        }
        
        return;
    }
    
    // -- Firmware Rev
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDFirmwareRevision]]) {
        if (data.length > 0) {
            workingDevice.firmwareRevision = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
////            APLog(@"--- FIRMWARE REV VALUE ---> %@", workingDevice.firmwareRevision);
        }
        
        return;
    }
    
    // -- Hardware Rev
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDHardwareRevision]]) {
        if (data.length > 0) {
            workingDevice.hardwareRevision = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
////            APLog(@"--- HARDWARE REV VALUE ---> %@", workingDevice.hardwareRevision);
        }
        
        return;
    }
    
    // -- Manufacturer
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDManufacturer]]) {
        if (data.length > 0) {
            workingDevice.manufacturer = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        return;
    }
    
    // -- Thermometer
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDThermoData]]) {
        [APBLEInterface temperatureValueForDevice:workingDevice fromData:data];
        
        return;
    }
    
    
    if (s_processing_restart) {
        NSLog(@"********######### 1 ##########***********");
    }
    
    
    // -- Switch Data
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDCareSentinelChar]]) {
        if (s_processing_restart) {
            NSLog(@"********######### 2 ##########***********");
        }
        
        if (data.length == 2) {      // -- Trigger is subject to muting...
            uint16_t    value = 0;
            [data getBytes:&value length:sizeof (value)];
            
            if (s_processing_restart) {
                NSLog(@"********######### 3 VALUE: %d ##########***********", value);
            }
            
/******
            if (!workingDevice.muteAll) {
                APBLESensor *sensor = nil;
                if (value & APSensorTriggerPad OR value & APSensorClearPad) {
                    sensor = [workingDevice getSensorType:APSensorTypePad];
                
                    if (sensor AND !sensor.muteTrigger) {
                        if (value & APSensorTriggerPad AND !sensor.triggered) {
                            if (sensor.triggerDelay == 0) {
                                // -- Triggered
                                [_delegate triggeredSensor:sensor];
                            } else {
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, sensor.triggerDelay * NSEC_PER_SEC);
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    // -- Make sure the sensor is still tirggered afte the delay.
                                    if (sensor.triggered) {
                                        [_delegate triggeredSensor:sensor];
                                    }
                                });
                            }
                        } else if (value & APSensorClearPad AND sensor.triggered) {
                            // -- Cleared
                            [_delegate clearedSensor:sensor];
                        }
                    }
                }
            }
            ******/
            [self.uiDelegate device:peripheral SensorChanged:value];
            
            if (value & APSensorTriggerBed OR value & APSensorClearBed) {
                [self processSensorType:APSensorTypeBed forSensor:workingDevice withValue:value];
            } else if (value & APSensorTriggerChair OR value & APSensorClearChair) {
                [self processSensorType:APSensorTypeChair forSensor:workingDevice withValue:value];
            } else if (value & APSensorTriggerToilet OR value & APSensorClearToilet) {
                [self processSensorType:APSensorTypeToilet forSensor:workingDevice withValue:value];
            } else if (value & APSensorTriggerDampness OR value & APSensorClearDampness) {
                [self processSensorType:APSensorTypeDampness forSensor:workingDevice withValue:value];
            } else if (value & APSensorTriggerPortal OR value & APSensorClearPortal) {
                [self processSensorType:APSensorTypePortal forSensor:workingDevice withValue:value];
            } else if (value & APSensorTriggerCall OR value & APSensorClearCall) {
                [self processSensorType:APSensorTypeCall forSensor:workingDevice withValue:value];
            }
        }
        
        return;
    }
    
    s_processing_restart = NO;
}

// -- Depricated in iOS8
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    [self peripheral:peripheral didReadRSSI:peripheral.RSSI error:error];   // -- Method depricated, pass it on to new one.
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    APBLEDevice *workingDevice = [self deviceForPeripheral:peripheral];
    
    if (!workingDevice OR error) return;
    
    workingDevice.RSSI = [RSSI integerValue];
    
    [workingDevice rssiToPercent];  // -- Convert RSSI on peripheral to percentage value.
    
    if ([_delegate respondsToSelector:@selector(rssiUpdatedForDevice:)])
        [_delegate rssiUpdatedForDevice:workingDevice];
    
    [self->_uiDelegate didUpdateDevice: peripheral];
}

// --------------------------------------------------------------------------------
#pragma mark - Private Methods
// --------------------------------------------------------------------------------


// --------------------------------------------------------------------------------
#pragma mark - Public Methods
// --------------------------------------------------------------------------------
- (void)removeRegisteredDevice:(APBLEDevice *)device {
    
    if ([APAppServices osVersion] >= 7.0f) {
        if (device.peripheral.state != CBPeripheralStateConnected AND device.peripheral.state != CBPeripheralStateConnecting) {
            [_centralManager cancelPeripheralConnection:device.peripheral];
        }
    } else {
#ifndef __IPHONE_7_0
        if (device.peripheral.isConnected) {
            [_centralManager cancelPeripheralConnection:device.peripheral];
        }
#endif
    }
    
    NSInteger index = 0;
    for (APBLEDevice *listDevice in _inactiveDevices) {
        if ([listDevice isEqual:device]) {
            [_inactiveDevices removeObjectAtIndex:index];
            break;
        }
        index++;
    }

    index = 0;
    for (APBLEDevice *listDevice in _activeDevices) {
        if ([listDevice isEqual:device]) {
            [_activeDevices removeObjectAtIndex:index];
            break;
        }
        index++;
    }
    
    index = 0;
    for (APBLEDevice *listDevice in _registeredArray) {
        if ([listDevice isEqual:device]) {
            [_registeredArray removeObjectAtIndex:index];
            break;
        }
        index++;
    }
    
    [APSettings saveDevicesArray:_registeredArray];
}

- (void)removeIgnoredDevice:(APBLEDevice *)device {
    NSInteger       index    = 0;
    for (APBLEDevice *listDevice in _ignoredArray) {
        if ([listDevice isEqual:device]) {
            [_ignoredArray removeObjectAtIndex:index];
            break;
        }
        index++;
    }
    
    [APSettings saveIgnoredArray:_ignoredArray];
}

- (BOOL)devicesWithlowBatteryLevel {
    // -- Unknown battery levels considered NO.
    
    for (APBLEDevice *device in _activeDevices) {
        if (device.batteryService) {
            if (device.batteryLow)  // -- Return on first low level found.
                return YES;
        }
    }
    
    return NO;
}

- (BOOL)devicesOutOfRange {
    for (APBLEDevice *device in _activeDevices) {
////        APLog(@"1. ESTIMATE SIGNAL PCT FOR: %@ IS: %d", device.name, device.signalPercent);
        if (device.signalPercent == 0) {
            return YES;
        }
    }
    
    return NO;
}

+ (int)batteryPercentUsingCharacteristic:(CBCharacteristic *)characteristic {
    if (!characteristic) return -1;
    
    int8_t	value = 0;
    
    NSData *data = characteristic.value;
    if (data.length == 1) {
        [data getBytes:&value length:sizeof (value)];
        
        APLog(@"BATT %%: %d", value);   // ######################
    } 
    return value;
}

// #################### PROTOTYPE ONLY #############################
+ (float)temperatureValueForDevice:(APBLEDevice *)device fromData:(NSData *)data {
    UInt8 flags = 0;
    [data getBytes:&flags length:1];
    
    int8_t exponent = 0;
    [data getBytes:&exponent range:NSMakeRange(4, 1)];
    
    int8_t third = 0;
    [data getBytes:&third range:NSMakeRange(3, 1)];
    int8_t second = 0;
    [data getBytes:&second range:NSMakeRange(2, 1)];
    int8_t first = 0;
    [data getBytes:&first range:NSMakeRange(1, 1)];
    
    int mantissa = ((third << 16) | (second << 8) | first);
    
    float value = mantissa * pow(10, exponent);
    
    if (exponent >= 0)
    exponent = 0;
    else
    exponent = abs(exponent);
    
    NSString *tempString = @"INVALID";  // ######################
    if (flags & kThermoFlagFahrenheit) {
        tempString = [NSString stringWithFormat:@"%.*f F", exponent, value];    // ######################
        device.tempInCelsius = NO;
    } else {
        tempString = [NSString stringWithFormat:@"%.*f C", exponent, value];    // ######################
        device.tempInCelsius = YES;
    }
    APLog(@" ---> TEMP: %@", tempString);   // ######################
    
    return value;
}

+ (float)temperatureForDevice:(APBLEDevice *)device UsingCharacteristic:(CBCharacteristic *)characteristic {
    if (!device OR !characteristic) return kDeviceInvalidTemp;
    
    [device.peripheral readValueForCharacteristic:characteristic];
    
    NSData *data = characteristic.value;
    
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kUUIDThermoData]]) {
        if (data.length == 5) {
            return [APBLEInterface temperatureValueForDevice:device fromData:data];
        }
        
        return kDeviceInvalidTemp;
    }
    return kDeviceInvalidTemp;
}
// #######################################################

// ------------------------------------------------------------------------------
#pragma mark - APBLEDeviceAddDelegate delegate
// ------------------------------------------------------------------------------
- (void)dismissAddView {
    UIViewController *vc = (UIViewController *)_delegate;
    [vc dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)useDevice:(APBLEDevice *)device {
    [self dismissAddView];
    
    device.muteAll = NO;        // -- Default to off.
    
    [_registeredArray addObject:device];
    [APSettings saveDevicesArray:_registeredArray];
    
    if (device AND device.peripheral) {
        device.peripheral.delegate = self;
        [self connectDevice:device];
    }
}

- (void)ignoreDevice:(APBLEDevice *)device {
    if (!device) return;
    
    [_centralManager cancelPeripheralConnection:device.peripheral];
    [device clearServicesAndCharacteristics];
    
    [_ignoredArray addObject:device];
    APLog(@"Ignoring: %@, %@", device.name, device.serialNumber);       // ######################
    [APSettings saveIgnoredArray:_ignoredArray];
    
    // -- Remove the device from the discovered array.
    [self removeDiscoveredPeripheral:device.peripheral];
    
    [self dismissAddView];
}
@end
