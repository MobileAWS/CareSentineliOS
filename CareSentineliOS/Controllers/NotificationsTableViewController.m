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
#import "MainTabsControllerViewController.h"

@interface NotificationsTableViewController (){
    NSMutableArray *notificationsData;
    NSMutableArray *sectionIndexes;
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
    notificationsData = [PropertiesDao listPropertiesForUser:self->application.currentUser.id];
    sectionIndexes = [[NSMutableArray alloc]init];
    NSNumber *lastId = 0;
    for (NSUInteger i = 0; i < notificationsData.count; i++) {
        NSNumber *currentId = ((DevicePropertyDescriptor *)notificationsData[i]).deviceId;
        if (![lastId isEqualToNumber:currentId]) {
            [sectionIndexes addObject:[NSIndexPath indexPathForItem:i inSection:[currentId integerValue]]];
            lastId = currentId;
        }
    }
    if (reloadTable) {
        [self->notificationsTable reloadData];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    MainTabsControllerViewController *tabController= (MainTabsControllerViewController *)[AppDelegate findSuperConstroller:self with:[MainTabsControllerViewController class]];
    if (tabController != nil){
        [tabController.tabBar.items[1] setBadgeValue:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSIndexPath *index = [self->sectionIndexes objectAtIndex:section];
    for (int i = 0; i < application.devicesData.count; i++) {
        Device *tmpDevice = (Device *)application.devicesData[i];
        if ([tmpDevice.id integerValue] == index.section) {
            return tmpDevice.name;
        }
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionIndexes.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (notificationsData != nil && notificationsData.count > 0) {
        Device * device = nil;
        NSIndexPath *index = [self->sectionIndexes objectAtIndex:section];
        for (int i = 0; i < application.devicesData.count; i++) {
            device = (Device *)application.devicesData[i];
            if ([device.id integerValue] == index.section) {
                break;
            }
        }
        
        int count = 0;
        for(int i = 0; i < notificationsData.count; i++){
            NSNumber *deviceId = ((DevicePropertyDescriptor *)[notificationsData objectAtIndex:i]).deviceId;
            if ([deviceId isEqualToNumber:device.id]) {
                count++;
            }
        }
        return count;
    }
    return 0;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationsCellIdentifier" forIndexPath:indexPath];
    NSIndexPath *section = [sectionIndexes objectAtIndex:indexPath.section];
    DevicePropertyDescriptor *descriptor = [notificationsData objectAtIndex:(section.item + indexPath.row)];

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

    tmpLabel = (UILabel *)[cell viewWithTag:4000];
    if (descriptor.dismissedAt != nil){
        tmpLabel.text = [NSString stringWithFormat:@"Acknowledged At %@",descriptor.dismissedAtDate];
    }else{
        tmpLabel.text = @"";
    }
        
    return cell;
}


@end
