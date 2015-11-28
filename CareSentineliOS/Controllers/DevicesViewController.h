//
//  DevicesViewController.h
//  CareSentineliOS
//
//  Created by Mike on 5/13/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertInputAcceptedDelegate.h"
#import "Device.h"

@interface DevicesViewController : UIViewController <AlertInputAcceptedDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
- (void)simulateAlertForDevice:(Device *)device;
- (void)reconnectDeviceForUUDID:(NSString *)identifier;
@end
