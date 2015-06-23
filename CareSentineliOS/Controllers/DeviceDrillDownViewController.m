//
//  DeviceDrillDownViewController.m
//  CareSentineliOS
//
//  Created by Mike on 6/20/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DeviceDrillDownViewController.h"
#import "UIResources.h"

@interface DeviceDrillDownViewController (){

    __weak IBOutlet UILabel *serialTextField;
    __weak IBOutlet UILabel *versionsTextField;
    
}
@end

@implementation DeviceDrillDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self->serialTextField.text = self.device.deviceDescriptor.serialNumber;
    self->versionsTextField.text = [NSString stringWithFormat:@"%@/%@",self.device.deviceDescriptor.hardwareRevision, self.device.deviceDescriptor.firmwareRevision];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
