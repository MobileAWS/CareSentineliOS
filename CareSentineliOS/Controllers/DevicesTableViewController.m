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

@interface DevicesTableViewController (){
    NSMutableArray *devicesData;
    __weak IBOutlet UITableView *targetTableView;
    __weak UIView *noRecordsView;
}
@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    self->devicesData = [manager listWithModel:[Device class] condition:@" id > 0"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    if (devicesData != nil && [devicesData count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
        if (noRecordsView == nil) {
            NSArray *emptyViews = [[NSBundle mainBundle] loadNibNamed:@"DevicesEmptyTableMessage" owner:self options:nil];
            // Display a message when the table is empty
            noRecordsView = [emptyViews objectAtIndex:0];

        }
        [noRecordsView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        self.tableView.backgroundView = noRecordsView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;        
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (devicesData != nil) {
        return devicesData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)targetTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [targetTable dequeueReusableCellWithIdentifier:@"DevicesTableCellIdentifier" forIndexPath:indexPath];
    Device *device = (Device *)devicesData[indexPath.row];
    ((UILabel *)[cell viewWithTag:1000]).text = device.name;
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:cell.frame];
    bgView.backgroundColor = selectionBackgroundColorRef;
    cell.selectedBackgroundView = bgView;
    return cell;
}

-(void)addDevice:(Device *)targetDevice{
    [devicesData addObject:targetDevice];
    [self->targetTableView reloadData];
}

-(BOOL)containsDevice:(NSString *)deviceUUID{
    for(int i = 0; i < [devicesData count]; i++){
        Device *currentDevice = (Device *)[devicesData objectAtIndex:i];
        if([currentDevice.hwId isEqualToString:deviceUUID]) {
            return YES;
        }
    }    
    return NO;
}

-(Device *)deviceForPeripheral:(NSString *)deviceUUID{
    for(int i = 0; i < [devicesData count]; i++){
        Device *currentDevice = (Device *)[devicesData objectAtIndex:i];
        if([currentDevice.hwId isEqualToString:deviceUUID]) {
            return currentDevice;
        }
    }
    return nil;
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
