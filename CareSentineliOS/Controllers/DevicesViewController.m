//
//  DevicesViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/13/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DevicesViewController.h"
#import "AppDelegate.h"
#import "DevicesTableViewController.h"

@interface DevicesViewController (){
    __weak DevicesTableViewController *devicesTableViewController;
}

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:0.09 green:0.74 blue: 0.75 alpha:0.6];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate logout];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EmbedDevicesViewControllerSegue"]){
        self->devicesTableViewController = segue.destinationViewController;    
    }
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
