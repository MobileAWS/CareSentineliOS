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
#import "UIResources.h"
#import "AppDelegate.h"

@interface MainTabsControllerViewController ()

@end

@implementation MainTabsControllerViewController

NSMutableArray *menuItemsOnline;
NSArray *menuControllersOffline;
NSMutableArray *mutableMenuControllesOffline;
UIButton *rightButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    [TSMessage setDefaultViewController:self];
    self.moreNavigationController.delegate = self;
    self.tabBarController.customizableViewControllers = nil;
    self.moreNavigationController.navigationBar.topItem.rightBarButtonItem = nil;
    self.moreNavigationController.navigationBar.tintColor    = [UIColor whiteColor];
    self.moreNavigationController.navigationBar.barTintColor=baseBackgroundColor;
    self.moreNavigationController.navigationBar.translucent = NO;
    [self.moreNavigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    rightButton = navigationController.navigationBar.topItem.rightBarButtonItem;
    if (   navigationController.tabBarController.selectedIndex >= 0 &&   navigationController.tabBarController.selectedIndex <= 5)
        
    {
        navigationController.navigationBar.topItem.rightBarButtonItem = rightButton;
    } else {
        navigationController.navigationBar.topItem.rightBarButtonItem = Nil;
    }
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
