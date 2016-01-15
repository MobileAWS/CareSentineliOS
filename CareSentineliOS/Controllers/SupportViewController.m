//
//  SupportViewController.m
//  CareSentineliOS
//
//  Created by Mike on 7/16/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "SupportViewController.h"
#import "UIResources.h"
#import "AppDelegate.h"
#import "LNNetworkManager.h"

@interface SupportViewController (){
__weak IBOutlet NSLayoutConstraint *logoutButtonWidthConstraint;
}

@end

@implementation SupportViewController
UIBarButtonItem *leftButton;
UIBarButtonItem *backButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    }

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AppDelegate checkLogoutWithButton:_logoutButton withConstraint:logoutButtonWidthConstraint];
    
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutAction:(id)sender {
    AppDelegate *delegeate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegeate logout:_logoutButton withConstraint:self->logoutButtonWidthConstraint];
    [self  barNavegationValidation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) setheader{
    self.navigationController.navigationBar.barTintColor = baseBackgroundColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [[UIColor alloc] initWithRed:1 green:1 blue: 1 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}
-(void) barNavegationValidation{
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;;
        [self setheader];
}
@end
