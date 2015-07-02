//
//  UploadDevicesTableViewController.h
//  CareSentineliOS
//
//  Created by Mike on 6/22/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNServerActionButtonDelegate.h"

@interface UploadDevicesTableViewController : UITableViewController
@property (readonly) NSMutableArray  *selectedDevices;
@property (weak,nonatomic) id<LNServerActionButtonDelegate> actionButtonsDelegate;
@end
