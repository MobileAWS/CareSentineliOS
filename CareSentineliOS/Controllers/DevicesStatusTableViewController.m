//
//  DevicesStatusTableViewController.m
//  CareSentineliOS
//
//  Created by Mike on 7/8/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DevicesStatusTableViewController.h"
#import "UIResources.h"
#import "AppDelegate.h"
#import "Device.h"
#import "DeviceEnabledProperty.h"

@interface DevicesStatusTableViewController (){
    __weak AppDelegate *application;
    __weak IBOutlet UITableView *targetTable;
}

@end

@implementation DevicesStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self->application = (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)viewDidDisappear:(BOOL)animated{
    if(application.switchChangedDelegate == self){
        application.switchChangedDelegate = nil;
    }
}

-(void)switchChangedForDevice:(Device *)device{
    for(int i = 0; i < self->application.devicesData.count; i++){
        if (((Device *)self->application.devicesData[i]).id == device.id) {
            [self->targetTable reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
    return;
}

-(void)viewDidAppear:(BOOL)animated{
    application.switchChangedDelegate = self;
    [self->targetTable reloadData];
}

- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Device *device = (Device *)self->application.devicesData[section];
    return device.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self->application != nil){
        return self->application.devicesData.count;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Device *device = (Device *)self->application.devicesData[section];
    return [device getCharacteristics].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceStatusCellReuseIdentifier" forIndexPath:indexPath];
    Device *device = (Device *)self->application.devicesData[indexPath.section];
    NSArray *characteristics = [device getCharacteristics];
    DeviceEnabledProperty *property = (DeviceEnabledProperty *)characteristics[indexPath.row];
    cell.textLabel.text = property.name;
    if ([device isOnForSwitch:property.name]){
        cell.textLabel.textColor = greenBaseColor;
    }else{
        cell.textLabel.textColor = [UIColor redColor];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
