//
//  DeviceDrillDownViewController.h
//  CareSentineliOS
//
//  Created by Mike on 6/20/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "AlertInputAcceptedDelegate.h"

@interface DeviceDrillDownViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,AlertInputAcceptedDelegate>
@property Device *device;
@property BOOL disconnect;
@property BOOL rename;
@end
