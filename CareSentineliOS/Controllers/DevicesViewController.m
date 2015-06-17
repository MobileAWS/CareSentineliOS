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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
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
}


/** Devices UI delegate code */

-(void)deviceDiscovered:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    Device *device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    if (device != nil) {
        if (!device.connected){
            device.connected = true;
            [self->devicesTableViewController reloadDevice:device];
        }        
        return;
    }

    Device *newDevice = [[Device alloc] init];
    newDevice.name = peripheral.name;
    newDevice.hwId = peripheral.identifier.UUIDString;
    [self->devicesTableViewController addDevice:newDevice];
}


-(void)device:(CBPeripheral *)peripheral SensorChanged:(uint16_t)value{
    Device * device = [self->devicesTableViewController deviceForPeripheral:peripheral.identifier.UUIDString];
    NSArray *changedSwitches = [device getChangedSwitch:value];
    if (changedSwitches != nil){
        
        NSMutableString *message = [[NSMutableString alloc]init];
        for (int i = 0; i < changedSwitches.count; i++) {
            NSDictionary *tmpObject = [changedSwitches objectAtIndex:i];
            NSString *name = [tmpObject objectForKey:@"propertyName"];
            NSString *value = [tmpObject objectForKey:@"value"];
            [PropertiesDao saveProperty:name forDevice:device withValue:value];
            [message appendString:[NSString stringWithFormat:@" %@ Has changed to %@\n",name,value]];
            
        }
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertTitle = @"Switch Changed";
        notification.alertBody = message;
        notification.soundName = @"default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
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
