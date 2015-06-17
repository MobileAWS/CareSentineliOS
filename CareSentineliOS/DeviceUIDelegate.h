//
//  DeviceUIDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 6/2/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DeviceUIDelegate
-(void)deviceDiscovered:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
-(void)device:(CBPeripheral *)peripheral SensorChanged:(uint16_t)value;
-(void)disconnectDevice:(CBPeripheral *)peripheral;
@end
