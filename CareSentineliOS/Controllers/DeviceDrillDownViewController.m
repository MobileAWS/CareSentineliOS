//
//  DeviceDrillDownViewController.m
//  CareSentineliOS
//
//  Created by Mike on 6/20/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DeviceDrillDownViewController.h"
#import "UIResources.h"
#import "DeviceEnabledProperty.h"
#import "AppDelegate.h"
#import "HexColor.h"

@interface DeviceDrillDownViewController (){

    __weak IBOutlet UILabel *serialTextField;
    __weak IBOutlet UILabel *versionsTextField;
    __weak IBOutlet UIImageView *signalImage;
    __weak IBOutlet UIImageView *batteryImage;
    __weak IBOutlet UILabel *temperatureLabel;
    __weak IBOutlet UITableView *characteristicsTable;
    __weak IBOutlet UIButton *disconnectButton;
}
@end

@implementation DeviceDrillDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.disconnect = NO;
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self->serialTextField.text = self.device.deviceDescriptor.serialNumber;
    self->versionsTextField.text = [NSString stringWithFormat:@"%@/%@",self.device.deviceDescriptor.hardwareRevision, self.device.deviceDescriptor.firmwareRevision];
    [self->batteryImage setImage:[self.device getImageForBattery]];
    self->batteryImage.tintColor = baseBackgroundColor;
    [self->signalImage setImage:[self.device getImageForSignal]];
    self->signalImage.tintColor = baseBackgroundColor;
    self->temperatureLabel.text = [self.device getTemperature];
    self.title = self.device.name;
    self->characteristicsTable.delegate = self;
    self->characteristicsTable.dataSource = self;
    
    self->disconnectButton.layer.borderWidth = 1.0f;
    self->disconnectButton.layer.cornerRadius = 8.0f;
    self->disconnectButton.layer.borderColor = [[UIColor colorWithHexString:@"#cc0000"] CGColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *characteristics = [self.device getCharacteristics];
    if (characteristics != nil) {
        return [characteristics count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSArray *characteristics = [self.device getCharacteristics];
    if (characteristics != nil) {
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DrillDownCaracteristicsReusableIdentifier" forIndexPath:indexPath];
    NSArray *characteristics = [self.device getCharacteristics];
    DeviceEnabledProperty *characteristic = [characteristics objectAtIndex:indexPath.row];
    BOOL isOn = [self.device isOnForSwitch:characteristic.name];

    
    UILabel *tmpLabel = (UILabel *)[cell viewWithTag:1000];
    tmpLabel.text = characteristic.name;
    if (!isOn) {
        tmpLabel.textColor = [UIColor redColor];
    }
    
    UISwitch *tmpSwitch = (UISwitch *)[cell viewWithTag:2000];
    tmpSwitch.on = [characteristic isEnabled];
    
    
    [tmpSwitch addTarget:self action:@selector(switchChanged:)forControlEvents:UIControlEventValueChanged];
    return cell;
}


-(void)switchChanged:(id)sender{
    
    UIView *superView = [((UISwitch *)sender) superview];
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView) {
        if ([superView isKindOfClass:[UITableViewCell class]]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    
    if (superView != nil){
        UITableViewCell *cell = (UITableViewCell *)superView;
        NSIndexPath *indexPath = [self->characteristicsTable indexPathForCell:cell];
        DeviceEnabledProperty *characteristic = [[self.device getCharacteristics] objectAtIndex:indexPath.row];
        [self.device switchCharacteristicStatus:characteristic.name];
    }
}


-(IBAction)disconnectDeviceAction:(id)sender{
    [AppDelegate showConfirmWith:NSLocalizedString(@"device.disconnect.confirm",nil) title:NSLocalizedString(@"device.disconnect.confirm.title",nil) target:nil callback:^{
            self.disconnect = YES;
            [self performSegueWithIdentifier:@"UnwindFromDrillDown" sender:self];
        }];

}

-(IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}
@end
