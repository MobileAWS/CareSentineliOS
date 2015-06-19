//
//  DeviceUIDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 6/2/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"

@protocol DeviceUIDelegate
-(BOOL)deviceDiscovered:(CBPeripheral *)peripheral withName:(NSString *)deviceName;
-(void)device:(CBPeripheral *)peripheral SensorChanged:(uint16_t)value;
-(void)disconnectDevice:(CBPeripheral *)peripheral;
-(Device *)deviceForUDID:(NSString *)udid;
-(void)deviceConnected:(CBPeripheral *)peripheral;
@end
