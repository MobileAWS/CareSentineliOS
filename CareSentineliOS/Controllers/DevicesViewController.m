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

@interface DevicesViewController() <DeviceUIDelegate>{
    __weak DevicesTableViewController *devicesTableViewController;
    APBLEInterface *bleInterface;
}

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self->bleInterface = [[APBLEInterface alloc] init];
    self->bleInterface.uiDelegate = self;
    ((AppDelegate *)[UIApplication sharedApplication].delegate).bleInterface = self->bleInterface;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
}


-(IBAction)scanButtonAction:(id)sender{
    [AppDelegate showLoadingMask];
    [self->bleInterface scanForDevices];
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
    NSArray *changedSwitches = [device getChangedSwitch:value];
    if (changedSwitches != nil && [changedSwitches count] > 0){
        
        NSMutableString *message = [[NSMutableString alloc]init];
        for (int i = 0; i < changedSwitches.count; i++) {
            NSDictionary *tmpObject = [changedSwitches objectAtIndex:i];
            NSString *name = [tmpObject objectForKey:@"propertyName"];
            NSString *value = [tmpObject objectForKey:@"value"];
            DeviceProperty *deviceProperty = [PropertiesDao saveProperty:name forDevice:device withValue:value];
            [message appendString:[NSString stringWithFormat:@" %@ Has changed to %@\n",name,value]];
            DevicePropertyDescriptor *descriptor = [[DevicePropertyDescriptor alloc]initWithProperty:deviceProperty AndDeviceName:device.name];
            device.lastPropertyChange = descriptor;
            device.lastPropertyMessage = message;
            [self->devicesTableViewController reloadDevice:device];
            
        }
     
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:@"Switch Changed" subtitle:message type:TSMessageNotificationTypeMessage duration:2];
            AudioServicesPlaySystemSound(1002);
        }
        else{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertTitle = @"Switch Changed";
            notification.alertBody = message;
            notification.soundName = @"default";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
            UIApplication *app = [UIApplication sharedApplication];
            NSInteger value = app.applicationIconBadgeNumber + changedSwitches.count;
            app.applicationIconBadgeNumber = value;
            [self updateNotificationsTab: value];
        }
        
        AppDelegate *application = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (application.switchChangedDelegate != nil){
            [application.switchChangedDelegate switchChangedForDevice:device];
        }
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
    if (device != nil) {
        if (device.connected){
            device.connected = false;
            [self->devicesTableViewController reloadDevice:device];
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
}


/** End - Devices UI delegate code */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
