//
//  DevicesTableViewController.h
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@interface DevicesTableViewController : UITableViewController
    -(void)addDevice:(Device *)targetDevice;
    -(BOOL)containsDevice:(NSString *)deviceUUID;
    -(Device *)deviceForPeripheral:(NSString *)deviceUUID;
    -(void)reloadDevice:(Device *)device;
    -(void)reloadDevices;
@end
