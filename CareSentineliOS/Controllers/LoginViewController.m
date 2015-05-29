//
//  LoginViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/8/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DatabaseManager.h"
#import "User.h"
#import "AppDelegate.h"

@interface LoginViewController (){
    
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *clientIdTextField;
    __weak IBOutlet UITextField *siteIdTextField;
    __weak IBOutlet UIButton *noCloudButton;
    __weak IBOutlet UIButton *loginButton;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGColorRef borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor];
    
    self->emailTextField.layer.borderColor = borderColor;
    self->emailTextField.layer.borderWidth = 1.0f;
    self->emailTextField.layer.cornerRadius = 8.0f;
    
    self->passwordTextField.layer.borderColor = borderColor;
    self->passwordTextField.layer.borderWidth = 1.0f;
    self->passwordTextField.layer.cornerRadius = 8.0f;

    self->clientIdTextField.layer.borderColor = borderColor;
    self->clientIdTextField.layer.borderWidth = 1.0f;
    self->clientIdTextField.layer.cornerRadius = 8.0f;


    self->siteIdTextField.layer.borderColor = borderColor;
    self->siteIdTextField.layer.borderWidth = 1.0f;
    self->siteIdTextField.layer.cornerRadius = 8.0f;
    
    self->loginButton.layer.borderWidth = 1.0f;
    self->loginButton.layer.cornerRadius = 8.0f;
    
    self->noCloudButton.layer.borderWidth = 1.0f;
    self->noCloudButton.layer.cornerRadius = 8.0f;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)doLogin{
    DatabaseManager *dbManager = [DatabaseManager getSharedIntance];
    User *user = (User *)[dbManager findWithCondition:[NSString stringWithFormat:@"email = '%@'",self->emailTextField.text] forModel:[User class]];
    if (user == nil) {
        [AppDelegate showAlert:@"This user does not exists" withTitle:@"Invalid Data"];
        return false;
    }
    
    if(![user.password isEqualToString:[User getEncryptedPasswordFor:self->passwordTextField.text]]){
        [AppDelegate showAlert:@"Invalid Password Provided" withTitle:@"Invalid Data"];
        return false;

    }
    
    return true;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (sender == self->loginButton){
        return [self doLogin];
    }
    
    return true;
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
