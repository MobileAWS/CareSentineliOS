//
//  DevicesTableViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DatabaseManager.h"
#import "Device.h"
#import <QuartzCore/QuartzCore.h>
#import "UIResources.h"
#import "AppDelegate.h"
#import "DataLabel.h"
#import "PropertiesDao.h"
#import "DevicesDao.h"
#import "DevicesViewController.h"

@interface DevicesTableViewController (){
    __weak IBOutlet UITableView *targetTableView;
    __weak UIView *noRecordsView;
    __weak AppDelegate *application;
    __weak IBOutlet NSLayoutConstraint *connectButtonX;
}
@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    application = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    application.devicesData = [manager listWithModel:[Device class] condition:[NSString stringWithFormat:@"(ignored = 0 OR ignored IS NULL) ORDER BY id"]];
    application.ignoredDevices = [manager listWithModel:[Device class] condition:[NSString stringWithFormat:@"(ignored = 1 ORDER BY id)"]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    BOOL validRecords = false;
    
    if (application.devicesData != nil && [application.devicesData count] > 0) {
        validRecords = true;
    }

    if (application.ignoredDevices != nil && [application.ignoredDevices count] > 0) {
        validRecords = true;
    }

    
    if (!validRecords){
        if (noRecordsView == nil) {
            NSArray *emptyViews = [[NSBundle mainBundle] loadNibNamed:@"DevicesEmptyTableMessage" owner:self options:nil];
            // Display a message when the table is empty
            noRecordsView = [emptyViews objectAtIndex:0];

        }
        [noRecordsView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.tableView.backgroundView = noRecordsView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (application.devicesData != nil){
            return application.devicesData.count;
        }
    }
    
    if (section == 1) {
        if (application.ignoredDevices != nil){
            return application.ignoredDevices.count;
        }
    }
    
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Active Devices";
    }
    return @"Ignored Devices";
}

- (UITableViewCell *)tableView:(UITableView *)targetTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [targetTable dequeueReusableCellWithIdentifier:@"DevicesTableCellIdentifier" forIndexPath:indexPath];    
    Device *device = [self getDeviceForIndex:indexPath];

    ((UILabel *)[cell viewWithTag:1000]).text = device.name;
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:cell.frame];
    
    if (![device isIgnored]) {
        UIButton *ignoredConnect = (UIButton *)[cell viewWithTag:8000];
        [ignoredConnect setHidden: true];

        BOOL connecting = false;
        if (device.connecting) {
            UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
            [tmpImageView setHidden:true];
            
            tmpImageView = (UIImageView *)[cell viewWithTag:3000];
            [tmpImageView setHidden:true];
            
            UIButton *tmpButton = (UIButton *)[cell viewWithTag:5000];
            [tmpButton setHidden:true];
            
            tmpButton = (UIButton *)[cell viewWithTag:7000];
            [tmpButton setHidden:true];
            
            UIActivityIndicatorView *tmpView = (UIActivityIndicatorView *)[cell viewWithTag:6000];
            if (!tmpView.isAnimating){
                [tmpView startAnimating];
            }
            [tmpView setHidden:false];
            connecting = true;
        }
        
    
        if (!connecting){
            
            UIActivityIndicatorView *tmpView = (UIActivityIndicatorView *)[cell viewWithTag:6000];
            if (tmpView.isAnimating){
                [tmpView stopAnimating];
            }
            [tmpView setHidden:true];

            if (device.connected) {
                UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
                [tmpImageView setHidden:false];
                [tmpImageView setImage:[device getImageForBattery]];
                tmpImageView.tintColor = baseBackgroundColorDarker;
                
                tmpImageView = (UIImageView *)[cell viewWithTag:3000];
                [tmpImageView setHidden:false];
                [tmpImageView setImage:[device getImageForSignal]];
                tmpImageView.tintColor = baseBackgroundColorDarker;
                
                UIButton *tmpButton = (UIButton *)[cell viewWithTag:5000];
                [tmpButton setHidden:true];
                
                tmpButton = (UIButton *)[cell viewWithTag:7000];
                [tmpButton setHidden:true];

            }else{
                UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
                [tmpImageView setHidden:true];
                [tmpImageView setImage:noBatteryImage];
                tmpImageView.tintColor = [UIColor redColor];
                
                tmpImageView = (UIImageView *)[cell viewWithTag:3000];
                [tmpImageView setHidden:true];
                [tmpImageView setImage:noSignalImage];
                tmpImageView.tintColor = [UIColor redColor];
                
                UIButton *tmpButton = (UIButton *)[cell viewWithTag:5000];
                [tmpButton setHidden:false];
                //tmpButton.layer.borderWidth = 1.0f;
                tmpButton.layer.cornerRadius = 8.0f;
                
                tmpButton = (UIButton *)[cell viewWithTag:7000];
                [tmpButton setHidden:false];
                
                //tmpButton.layer.borderWidth = 1.0f;
                tmpButton.layer.cornerRadius = 8.0f;
            }
        }

        if (device.lastPropertyMessage != nil) {
            DataLabel *alertLabel = (DataLabel *)[cell viewWithTag:4000];
            [alertLabel setHidden:false];
            alertLabel.layer.borderWidth = 1.0f;
            alertLabel.layer.cornerRadius = 8.0f;
            alertLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
            alertLabel.text = device.lastPropertyMessage;
            alertLabel.targetData = cell;
            [alertLabel.layer setMasksToBounds:YES];
        }
        else{
            DataLabel *alertLabel = (DataLabel *)[cell viewWithTag:4000];
            [alertLabel setHidden:true];
            [alertLabel.layer setMasksToBounds:YES];

        }
    }
    else{
        UIButton *ignoredConnect = (UIButton *)[cell viewWithTag:8000];
        [ignoredConnect setHidden: false];
        ignoredConnect.layer.cornerRadius = 8.0f;        
        
        UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
        [tmpImageView setHidden:true];
        
        tmpImageView = (UIImageView *)[cell viewWithTag:3000];
        [tmpImageView setHidden:true];
        
        DataLabel *alertLabel = (DataLabel *)[cell viewWithTag:4000];
        [alertLabel setHidden:true];
        
        UIButton *loadingButton = (UIButton *)[cell viewWithTag:6000];
        [loadingButton setHidden:true];
        
        UIButton *tmpButton = (UIButton *)[cell viewWithTag:5000];
        [tmpButton setHidden:true];
        tmpButton.layer.cornerRadius = 8.0f;
        
        tmpButton = (UIButton *)[cell viewWithTag:6000];
        [tmpButton setHidden:true];

        
        tmpButton = (UIButton *)[cell viewWithTag:7000];
        [tmpButton setHidden:true];
    }
    
    cell.selectedBackgroundView = bgView;
    return cell;
}

-(Device *)getDeviceForIndex:(NSIndexPath *)index{
    if (index.section == 0){
        if (application.devicesData.count > index.row) {
            return application.devicesData[index.row];
        }
        return nil;
    }
    
    if (application.ignoredDevices.count > index.row) {
        return application.ignoredDevices[index.row];
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device = [self getDeviceForIndex:indexPath];
    if([device isIgnored] ){
        return 44;
    }
    return device.lastPropertyMessage == nil? 44 : 90;
}

-(void)addDevice:(Device *)targetDevice{
    if (targetDevice.id == nil) {
        DatabaseManager *dbManager = [DatabaseManager getSharedIntance];
        targetDevice = (Device *)[dbManager save:targetDevice];
        [targetDevice setupCharacteristics];
    }
    if (![targetDevice isIgnored]){
        [application.devicesData addObject:targetDevice];
    }
    else{
        [application.ignoredDevices addObject:targetDevice];
    }
    
    [self->targetTableView reloadData];
}

-(void)reloadDevice:(Device *)device{
    NSInteger index = [application.devicesData indexOfObject:device];
    [self->targetTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)reloadDevices{
    [self->targetTableView reloadData];
}
-(BOOL)containsDevice:(NSString *)deviceUUID{
    for(int i = 0; i < [application.devicesData count]; i++){
        Device *currentDevice = (Device *)[application.devicesData objectAtIndex:i];
        if([currentDevice.uuid isEqualToString:deviceUUID]) {
            return YES;
        }
    }    
    return NO;
}

-(Device *)deviceForPeripheral:(NSString *)deviceUUID{
    for(int i = 0; i < [application.devicesData count]; i++){
        Device *currentDevice = (Device *)[application.devicesData objectAtIndex:i];
        if([currentDevice.uuid isEqualToString:deviceUUID]) {
            return currentDevice;
        }
    }
    
    for(int i = 0; i < [application.ignoredDevices count]; i++){
        Device *currentDevice = (Device *)[application.ignoredDevices objectAtIndex:i];
        if([currentDevice.uuid isEqualToString:deviceUUID]) {
            return currentDevice;
        }
    }

    return nil;
}

-(void)dismissAlertForDevice:(Device *)device andRow:(NSInteger)row{
    [PropertiesDao dismistProperty: device.lastPropertyChange.id];
    device.lastPropertyMessage = nil;
    device.lastPropertyChange = nil;
    
    [self->targetTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)dismissAlert:(id)sender {        
    CGPoint point = [((UITapGestureRecognizer *)sender) locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    Device *device = (Device *)application.devicesData[indexPath.row];
    [self dismissAlertForDevice:device andRow:indexPath.row];
}
- (IBAction)connectDeviceAction:(id)sender {
    CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    Device *device = (Device *)application.devicesData[indexPath.row];
    DevicesViewController *superController = (DevicesViewController *)[AppDelegate findSuperConstroller:self with:DevicesViewController.class];
    device.manuallyDisconnected = false;
    [superController reconnectDeviceForUUDID:device.uuid];
}

- (IBAction)connectIgnoredDevice:(id)sender {
    CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    Device *device = (Device *)application.ignoredDevices[indexPath.row];
    [application.ignoredDevices removeObject:device];
    device.ignored = false;
    device.connected = false;
    device.connecting = false;
    device.manuallyDisconnected = false;
    [application.devicesData addObject:device];
    DatabaseManager *dbManager = [DatabaseManager getSharedIntance];
    device = (Device *)[dbManager save:device];
    DevicesViewController *superController = (DevicesViewController *)[AppDelegate findSuperConstroller:self with:DevicesViewController.class];
    [self.tableView reloadData];
    [superController reconnectDeviceForUUDID:device.uuid];
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device = [self getDeviceForIndex:indexPath];
    if (device != nil && ![device isIgnored]){
        
        if (device.lastPropertyChange != nil && device.lastPropertyMessage != nil) {
            [self dismissAlertForDevice:device andRow:indexPath.row];
            return;
        }
        
        if (self->application.demoMode){
            DevicesViewController *superController = (DevicesViewController *)[AppDelegate findSuperConstroller:self with:DevicesViewController.class];
            [superController simulateAlertForDevice:device];
        }
        
        if (device.connecting){
            return;
        }

        if (device.connected == TRUE) {
            [[self parentViewController]performSegueWithIdentifier:@"ShowSensorDrillDown" sender:device];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    /*Device *device = [self getDeviceForIndex:indexPath];
    if(device != nil){
        return !device.connected;
    }*/
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    /*[AppDelegate showConfirmWith:@"This device and all it's associated data and notifications will be deleted. This action cannot be undone. Are you sure you want to delete this device?" title:@"Delete Device" target:nil callback:^{
        Device *device = [self getDeviceForIndex:indexPath];
        [DevicesDao deleteDeviceData:device];
        if (indexPath.section == 0){
            [application.devicesData removeObject:device];
        }
        else{
            [application.ignoredDevices removeObject:device];
        }
        [self->targetTableView reloadData];
    }];*/
}
- (IBAction)connectButtonDragInside:(id)sender {
    CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [[self.tableView cellForRowAtIndexPath:indexPath] setEditing:true animated:true];
}
- (IBAction)deleteAction:(id)sender {
    CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [AppDelegate showConfirmWith:@"This device and all it's associated data and notifications will be deleted. This action cannot be undone. Are you sure you want to delete this device?" title:@"Delete Device" target:nil callback:^{
        Device *device = [self getDeviceForIndex:indexPath];
        [DevicesDao deleteDeviceData:device];
        if (indexPath.section == 0){
            [application.devicesData removeObject:device];
        }
        else{
            [application.ignoredDevices removeObject:device];
        }
        [self->targetTableView reloadData];
    }];
}

@end
