//
//  MainTabsControllerViewController.m
//  CareSentineliOS
//
//  Created by Mike on 6/17/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "MainTabsControllerViewController.h"
#import "TSMessage.h"
#import "LNNetworkManager.h"
#import "AppDelegate.h"

@interface MainTabsControllerViewController ()

@end

@implementation MainTabsControllerViewController

NSMutableArray *menuItemsOnline;
NSArray *menuControllersOffline;
NSMutableArray *mutableMenuControllesOffline;

- (void)viewDidLoad {
    [super viewDidLoad];
    [TSMessage setDefaultViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)  viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) getOfflineMenu{
    if([LNNetworkManager sessionValid]){
        [self setViewControllers: menuItemsOnline];
    }else{
        [self setViewControllers:mutableMenuControllesOffline];
    }
}
@end
