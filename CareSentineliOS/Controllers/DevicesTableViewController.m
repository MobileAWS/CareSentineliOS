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

@interface DevicesTableViewController (){
    __weak IBOutlet UITableView *targetTableView;
    __weak UIView *noRecordsView;
    __weak AppDelegate *application;
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
    application.devicesData = [manager listWithModel:[Device class] condition:@" ignored = 0 OR ignored IS NULL"];
    application.ignoredDevices = [manager listWithModel:[Device class] condition:@" ignored = 1"];
    
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
        if (device.connected) {
            UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
            [tmpImageView setHidden:false];
            [tmpImageView setImage:[device getImageForBattery]];
            tmpImageView.tintColor = baseBackgroundColor;
            
            tmpImageView = (UIImageView *)[cell viewWithTag:3000];
            [tmpImageView setHidden:false];
            [tmpImageView setImage:[device getImageForSignal]];
            tmpImageView.tintColor = baseBackgroundColor;
            
        }else{
            UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
            [tmpImageView setImage:noBatteryImage];
            tmpImageView.tintColor = [UIColor redColor];
            
            tmpImageView = (UIImageView *)[cell viewWithTag:3000];
            [tmpImageView setImage:noSignalImage];
            tmpImageView.tintColor = [UIColor redColor];
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
        UIImageView *tmpImageView = (UIImageView *)[cell viewWithTag:2000];
        [tmpImageView setHidden:true];
        
        tmpImageView = (UIImageView *)[cell viewWithTag:3000];
        [tmpImageView setHidden:true];
        
        DataLabel *alertLabel = (DataLabel *)[cell viewWithTag:4000];
        [alertLabel setHidden:true];
    }
    
    //bgView.backgroundColor = selectionBackgroundColorRef;
    
    cell.selectedBackgroundView = bgView;
    return cell;
}

-(Device *)getDeviceForIndex:(NSIndexPath *)index{
    if (index.section == 0){
        return application.devicesData[index.row];
    }
    
    return application.ignoredDevices[index.row];
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
        targetDevice.customerId = application.currentCustomer.id;
        targetDevice.siteId = application.currentSite.id;
        targetDevice.userId = application.currentUser.id;
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

- (IBAction)dismissAlert:(id)sender {
    
    UIView *superView = [((UITapGestureRecognizer *)sender).view superview];
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
        NSIndexPath *indexPath = [self->targetTableView indexPathForCell:cell];
        Device *device = (Device *)application.devicesData[indexPath.row];
        
        [PropertiesDao dismistProperty: device.lastPropertyChange.id];
        device.lastPropertyMessage = nil;
        device.lastPropertyChange = nil;

        [self->targetTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    

}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device = [self getDeviceForIndex:indexPath];
    if (device != nil && ![device isIgnored] && device.connected == TRUE){
        [[self parentViewController]performSegueWithIdentifier:@"ShowSensorDrillDown" sender:device];
    }
}

@end
