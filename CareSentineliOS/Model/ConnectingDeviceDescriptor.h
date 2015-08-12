//
//  ConnectingDeviceDescriptor.h
//  CareSentineliOS
//
//  Created by Mike on 8/6/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ConnectingDeviceDescriptor : NSObject
@property (strong,nonatomic) NSTimer *timer;
@property (strong,nonatomic) CBPeripheral *device;
@end
