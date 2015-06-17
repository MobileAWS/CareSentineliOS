//
//  NotificationsTableViewController.m
//  CareSentineliOS
//
//  Created by Mike on 6/12/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "NotificationsTableViewController.h"
#import "AppDelegate.h"
#import "PropertiesDao.h"
#import "DevicePropertyDescriptor.h"
#import "UIResources.h"

@interface NotificationsTableViewController (){
    NSMutableArray *notificationsData;
    __weak IBOutlet UITableView *notificationsTable;
    __weak AppDelegate *application;
}

@end

@implementation NotificationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self->application = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self reloadWithTable:false];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadWithTable:true];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload)name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification  object:nil];
}

- (void)reload{
    [self reloadWithTable:true];
}


- (void)reloadWithTable:(BOOL)reloadTable{
    NSLog(@"Reloading Notifications Table");
    notificationsData = [PropertiesDao listPropertiesForUser:self->application.currentUser.id];
    if (reloadTable) {
        [self->notificationsTable reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Device *device = (Device *)[self->application.devicesData objectAtIndex:section];
    return device.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (notificationsData != nil && notificationsData.count > 0) {
        return [self->application.devicesData count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (notificationsData != nil && notificationsData.count > 0) {
        return notificationsData.count;
    }
    return 0;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsCellIdentifier" forIndexPath:indexPath];
    DevicePropertyDescriptor *descriptor = [notificationsData objectAtIndex:indexPath.row];

    /** Set Property Name */
    UILabel *tmpLabel = (UILabel *)[cell viewWithTag:1000];
    tmpLabel.text = descriptor.propertyName;
    
    /** Set Property Value  */
    tmpLabel = (UILabel *)[cell viewWithTag:2000];
    tmpLabel.text = descriptor.value;
    if ([descriptor.value isEqualToString:@"On"]) {
        tmpLabel.textColor = baseBackgroundColor;
    }
    
    if ([descriptor.value isEqualToString:@"Off"]) {
        tmpLabel.textColor = [UIColor redColor];
    }

    
    /** Set the event date/time */
    tmpLabel = (UILabel *)[cell viewWithTag:3000];
    tmpLabel.text = descriptor.createdAtDate;
        
    return cell;
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
