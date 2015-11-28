//
//  UploadViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/13/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "UploadViewController.h"
#import "AppDelegate.h"
#import "UIResources.h"
#import "LNNetworkManager.h"
#import "UploadDevicesTableViewController.h"
#import "PropertiesDao.h"

@interface UploadViewController (){
    __weak AppDelegate *application;
    __weak UploadDevicesTableViewController *uploadDevicesTableViewController;
    __weak IBOutlet UIButton *sendButton;
}

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([AppDelegate isValidLoggin]){
        _logoutButton.hidden = NO;
    }else {
        _logoutButton.hidden = YES;
    }
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self->application = (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EmbedUploadDevicesTableViewController"]) {
        self->uploadDevicesTableViewController = segue.destinationViewController;
        self->uploadDevicesTableViewController.actionButtonsDelegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonAction:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
}

- (IBAction)sendDataAction:(id)sender {
    NSArray *devices = uploadDevicesTableViewController.selectedDevices;
    if (devices.count <= 0) {
        return;
    }
    //[AppDelegate showLoadingMaskWith:@"Uploading Data"];
    [LNNetworkManager uploadData:devices onSucess:^(NSMutableArray *sucessDevices){
        if (sucessDevices.count > 0) {
            [PropertiesDao removeValuesForDevices:sucessDevices];
            [AppDelegate hideLoadingMask];
            [AppDelegate showAlert:@"Data Uploaded Successfully" withTitle:@"Data Upload"];
        }
        else{
            [AppDelegate hideLoadingMask];
            [AppDelegate showAlert:@"No data to upload was found" withTitle:@"Data Upload"];
        }
    } onFailure:^(NSError *error) {
        [AppDelegate hideLoadingMask];
        [AppDelegate showAlert:@"Upload Failed, please check your internet connection." withTitle:@"Error"];
    }];
}

-(void)enableActionButtons{
    [self->sendButton setEnabled:true];
}

-(void)disableActionButtons{
    [self->sendButton setEnabled:false];
}

@end
