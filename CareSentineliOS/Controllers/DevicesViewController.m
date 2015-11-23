//
//  DevicesViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/13/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DevicesViewController.h"
#import "AppDelegate.h"
#import "DevicesTableViewController.h"
#import "APBLEInterface.h"
#import "UIResources.h"
#import "PropertiesDao.h"
#import "TSMessage.h"
#import "DeviceDrillDownViewController.h"
#import "MainTabsControllerViewController.h"
#import "DatabaseManager.h"
#include <AudioToolbox/AudioToolbox.h>
#import "InputAlertViewDelegate.h"
#import "LNConstants.h"

@interface DevicesViewController() <DeviceUIDelegate>{
    __weak DevicesTableViewController *devicesTableViewController;
    APBLEInterface *bleInterface;
    __weak AppDelegate *application;
    InputAlertViewDelegate *currentDelegate;
}

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    self->application = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    if (!self->application.automaticStart){
        self->bleInterface = [[APBLEInterface alloc] init];
        self->bleInterface.uiDelegate = self;
        ((AppDelegate *)[UIApplication sharedApplication].delegate).bleInterface = self->bleInterface;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self->bleInterface == nil){
        self->bleInterface = [[APBLEInterface alloc] init];
        self->bleInterface.uiDelegate = self;
        ((AppDelegate *)[UIApplication sharedApplication].delegate).bleInterface = self->bleInterface;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadDevices{
    [self->devicesTableViewController reloadDevices];
}
- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
}

- (IBAction)demoModeActivate:(id)sender {
    application.demoMode = true;
    [AppDelegate showAlert: NSLocalizedString(@"demo.mode.activated",nil) withTitle:NSLocalizedString(@"demo.mode.activated.title",nil)];
}

-(IBAction)scanButtonAction:(id)sender{
    if (application.demoMode) {
        [self simulateDeviceConnected];
    }
    else{
        [AppDelegate showLoadingMask];
        [self->bleInterface scanForDevices];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EmbedDevicesViewControllerSegue"]){
        self->devicesTableViewController = segue.destinationViewController;    
    }
    
    if ([segue.identifier isEqualToString:@"ShowSensorDrillDown"]) {
        DeviceDrillDownViewController *destination = (DeviceDrillDownViewController *)[segue.destinationViewController viewControllers][0];
        destination.device = sender;
    }
}

-(void)setDevice:(CBPeripheral *)peripheral connectingStatus:(BOOL) status{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    device.connecting = status;
    [self->devicesTableViewController reloadDevice:device];
    
}

- (void)reconnectDeviceForUUDID:(NSString *)identifier{
    [bleInterface reconnectDeviceForUUDID:identifier];
}

/** Devices UI delegate code */
-(void)deviceConnected:(CBPeripheral *)peripheral phsyicalDevice:(APBLEDevice *)physDev{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    if (device != nil) {
        device.deviceDescriptor = physDev;
        if (!device.connected){
            device.connected = true;
            [self->devicesTableViewController reloadDevice:device];
        }
        return;
    }
    return;
}


-(Device *)deviceForUDID:(NSString *)udid{
    return [self->devicesTableViewController deviceForPeripheral:udid];
}


-(BOOL)deviceDiscovered:(CBPeripheral *)peripheral withName:(NSString *)deviceName{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    if (device != nil) {
        if (!device.connected){
            device.connected = true;
            [self->devicesTableViewController reloadDevice:device];
        }
        return true;
    }
    Device *newDevice = [[Device alloc] init];
    newDevice.name = deviceName;
    newDevice.uuid = peripheral.identifier.UUIDString;
    newDevice.hwName = peripheral.name;
    [self->devicesTableViewController addDevice:newDevice];
    return true;
}

-(BOOL)deviceIgnored:(CBPeripheral *)peripheral{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    if (device != nil) {
        if (device.connected){
            device.connected = false;
        }

        if ([device isIgnored]) {
            return true;
        }
        device.ignored = [[NSNumber alloc] initWithInt:1];
        [self->devicesTableViewController reloadDevice:device];
        return true;
    }
    
    Device *newDevice = [[Device alloc] init];
    newDevice.name = peripheral.name;
    newDevice.hwName = peripheral.name;
    newDevice.uuid = peripheral.identifier.UUIDString;
    newDevice.ignored = [[NSNumber alloc] initWithInt:1];
    [self->devicesTableViewController addDevice:newDevice];
    return true;
}


-(void)device:(CBPeripheral *)peripheral SensorChanged:(uint16_t)value{
    Device * device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    BOOL wasInitialized = device.initialized;
    NSArray *changedSwitches = [device getChangedSwitch:value];
    if (wasInitialized){
        if (changedSwitches != nil && [changedSwitches count] > 0){
            
            NSMutableString *message = [[NSMutableString alloc]init];
            for (int i = 0; i < changedSwitches.count; i++) {
                NSDictionary *tmpObject = [changedSwitches objectAtIndex:i];
                NSString *name = [tmpObject objectForKey:@"propertyName"];
                NSString *value = [tmpObject objectForKey:@"value"];
                NSString *baseName = [tmpObject objectForKey:@"baseName"];
                DeviceProperty *deviceProperty = [PropertiesDao saveProperty:baseName forDevice:device withValue:value];
                
                NSString *result = [NSString stringWithFormat:@"%@.%@",name,[value lowercaseString]];
                [message appendString:NSLocalizedString(result, nil)];
                DevicePropertyDescriptor *descriptor = [[DevicePropertyDescriptor alloc]initWithProperty:deviceProperty AndDeviceName:device.name];
                device.lastPropertyChange = descriptor;
                device.lastPropertyMessage = message;
                [self->devicesTableViewController reloadDevice:device];
                
            }
            
            [self sendNotificationWithTitle:NSLocalizedString(@"sensor.change.title", nil) andMessage:[NSString stringWithFormat:@"%@ on %@",message,device.name]  useBadge:true withCount:changedSwitches.count];
        }
        
    }
    
    if (application.switchChangedDelegate != nil){
        [application.switchChangedDelegate switchChangedForDevice:device];
    }

}

-(void)updateNotificationsTab:(NSInteger)count{
    MainTabsControllerViewController *tabController= (MainTabsControllerViewController *)[AppDelegate findSuperConstroller:self with:[MainTabsControllerViewController class]];
    if (tabController != nil){
        [tabController.tabBar.items[1] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)count]];
    }
}

-(void)disconnectDevice:(CBPeripheral *)peripheral{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    [self disconnectWithDevice:device];
}

-(void)disconnectWithDevice:(Device *)device{
    if (device != nil) {
        if (device.connected){
            device.connected = false;
            [self->devicesTableViewController reloadDevice:device];
            
            if (application.switchChangedDelegate != nil){
                [application.switchChangedDelegate switchChangedForDevice:device];
            }
            
            if (!device.connecting && !device.manuallyDisconnected) {
                [self sendNotificationWithTitle:NSLocalizedString(@"sensor.notification.disconnected.title", nil) andMessage:[NSString stringWithFormat:NSLocalizedString(@"sensor.notification.disconnected.message", nil),device.name]  useBadge:false withCount:0];
            }

        }
        return;
    }
}



-(void)didUpdateDevice:(CBPeripheral *) peripheral{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    if (device != nil) {
        if (device.connected){
            [self->devicesTableViewController reloadDevice:device];
        }
    }
}

-(void)didUpdateHwIdForDevice:(CBPeripheral *)peripheral{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    if (device != nil) {
        device.hwId = device.deviceDescriptor.serialNumber;
        [[DatabaseManager getSharedIntance] save:device];
    }

}

-(IBAction)unwindFromDrillDown:(UIStoryboardSegue *)segue{
    DeviceDrillDownViewController *drillDown =  (DeviceDrillDownViewController *)segue.sourceViewController;
    NSLog(@"segue %d",drillDown.disconnect);
    if (drillDown.rename) {
        [self->devicesTableViewController reloadDevice:drillDown.device];
    }
    
    if(drillDown.disconnect == YES){
        [self->bleInterface disconnectPeripheralForDevice:drillDown.device];
    }
}


/** End - Devices UI delegate code */

/** Demo Mode Methods */

-(void) input:(NSString *)input AcceptedWithObject:(id)target{
    /** Demo mode code */
    Device *newDevice = [[Device alloc] init];
    newDevice.name = input;
    newDevice.hwId = [NSString stringWithFormat:@"%@ - %X",input, arc4random_uniform(10000000)];
    newDevice.uuid = [NSString stringWithFormat:@"%@-%X-%X",@"68753A44-4D6F-1226",arc4random_uniform(10000000),arc4random_uniform(10000000)];
    newDevice.hwName = input;
    [self->devicesTableViewController addDevice:newDevice];

}

-(void)declinedWithObject:(id)target{
}

- (void)simulateDeviceConnected{
    
    InputAlertViewDelegate *inputDelegate = [[InputAlertViewDelegate alloc]init];
    inputDelegate.delegate = self;
    inputDelegate.targetObject = @"FAKE_DEVICE_ADDED";
    self->currentDelegate = inputDelegate;
    [AppDelegate showInputWith:NSLocalizedString(@"sensor.new.found", nil) title:@"New Monitor Device" defaultText:@"Test Sensor" delegate:inputDelegate cancelText:@"Not Mine" acceptText:@"Use It"];
    
}

- (void)simulateAlertForDevice:(Device *)device{

    NSString *valueString = @"value";
    NSString *propertyName = @"propertyName";
    NSString *baseName = @"baseName";
    NSString *on = @"On";
    NSString *off = @"Off";

    int val = arc4random_uniform(6);
    NSMutableArray *changedSwitches = [[NSMutableArray alloc] init];


    if (val % 6 == 0) {
        [changedSwitches addObject:@{baseName:CALL_SENSOR_PROPERTY_NAME,propertyName:CALL_SENSOR_PROPERTY_KEY,valueString:on}];
    }else if(val % 5 == 0){
        [changedSwitches addObject:@{baseName:BED_SENSOR_PROPERTY_NAME,propertyName:BED_SENSOR_PROPERTY_KEY,valueString:off}];
    }else if(val % 4 == 0){
        [changedSwitches addObject:@{baseName:CHAIR_SENSOR_PROPERTY_NAME,propertyName:CHAIR_SENSOR_PROPERTY_KEY,valueString:on}];
    }else if(val % 3 == 0){
        [changedSwitches addObject:@{baseName:INCONTINENCE_SENSOR_PROPERTY_NAME,propertyName:INCONTINENCE_SENSOR_PROPERTY_KEY,valueString:on}];
    }else if(val % 2 == 0){
        [changedSwitches addObject:@{baseName:TOILET_SENSOR_PROPERTY_NAME,propertyName:TOILET_SENSOR_PROPERTY_KEY,valueString:on}];
    }else{
        [changedSwitches addObject:@{baseName:TOILET_SENSOR_PROPERTY_NAME,propertyName:BED_SENSOR_PROPERTY_KEY,valueString:on}];
    }
    

    if (changedSwitches != nil && [changedSwitches count] > 0){
        
        NSMutableString *message = [[NSMutableString alloc]init];
        for (int i = 0; i < changedSwitches.count; i++) {
            NSDictionary *tmpObject = [changedSwitches objectAtIndex:i];
            NSString *name = [tmpObject objectForKey:@"propertyName"];
            NSString *value = [tmpObject objectForKey:@"value"];
            NSString *baseName = [tmpObject objectForKey:@"baseName"];
            DeviceProperty *deviceProperty = [PropertiesDao saveProperty:baseName forDevice:device withValue:value];
            
            NSString *result = [NSString stringWithFormat:@"%@.%@",name,[value lowercaseString]];
            [message appendString:NSLocalizedString(result, nil)];
            DevicePropertyDescriptor *descriptor = [[DevicePropertyDescriptor alloc]initWithProperty:deviceProperty AndDeviceName:device.name];
            device.lastPropertyChange = descriptor;
            device.lastPropertyMessage = message;
            [self->devicesTableViewController reloadDevice:device];
            
        }
        
        [self sendNotificationWithTitle:NSLocalizedString(@"sensor.change.title", nil) andMessage:[NSString stringWithFormat:@"%@ on %@",message,device.name]  useBadge:true withCount:changedSwitches.count];
    }
    
    if (application.switchChangedDelegate != nil){
        [application.switchChangedDelegate switchChangedForDevice:device];
    }
    

}

-(void)sendNotificationWithTitle:(NSString *)title andMessage:(NSString *)message useBadge:(BOOL)useBadge withCount:(NSInteger)count{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:title subtitle:message type:TSMessageNotificationTypeMessage duration:2];
        AudioServicesPlaySystemSound(1002);
    }
    else{
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertTitle = title;
        notification.alertBody = message;
        notification.soundName = @"default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        if (useBadge) {
            UIApplication *app = [UIApplication sharedApplication];
            NSInteger value = app.applicationIconBadgeNumber + count;
            app.applicationIconBadgeNumber = value;
            [self updateNotificationsTab: value];

        }
    }

}

@end
