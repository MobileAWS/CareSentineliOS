//
//  NotificationsViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/13/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "UIResources.h"
#import "DatabaseManager.h"
#import "DeviceProperty.h"
#import "PropertiesDao.h"
#import "NotificationsTableViewController.h"

@interface NotificationsViewController (){
    __weak NotificationsTableViewController *notificationsTable;
}

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EmbedNotificationsTableViewSegue"]){
        self->notificationsTable = segue.destinationViewController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logout];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end