//
//  NewUserViewController.m
//  CareSentineliOS
//
//  Created by Mike on 5/26/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "NewUserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "User.h"
#import "DatabaseManager.h"

@interface NewUserViewController (){
    
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *confirmEmail;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *confirmPassword;
    __weak IBOutlet UITextField *clientIdTextField;
    __weak IBOutlet UITextField *siteIdTextField;
    __weak IBOutlet UIButton *createButton;
    __weak IBOutlet UIButton *cancelButton;
}
@end

@implementation NewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGColorRef borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor];
    
    self->emailTextField.layer.borderColor = borderColor;
    self->emailTextField.layer.borderWidth = 1.0f;
    self->emailTextField.layer.cornerRadius = 8.0f;
    
    self->confirmEmail.layer.borderColor = borderColor;
    self->confirmEmail.layer.borderWidth = 1.0f;
    self->confirmEmail.layer.cornerRadius = 8.0f;
    
    self->passwordTextField.layer.borderColor = borderColor;
    self->passwordTextField.layer.borderWidth = 1.0f;
    self->passwordTextField.layer.cornerRadius = 8.0f;
    
    self->confirmPassword.layer.borderColor = borderColor;
    self->confirmPassword.layer.borderWidth = 1.0f;
    self->confirmPassword.layer.cornerRadius = 8.0f;

    
    self->clientIdTextField.layer.borderColor = borderColor;
    self->clientIdTextField.layer.borderWidth = 1.0f;
    self->clientIdTextField.layer.cornerRadius = 8.0f;
    
    
    self->siteIdTextField.layer.borderColor = borderColor;
    self->siteIdTextField.layer.borderWidth = 1.0f;
    self->siteIdTextField.layer.cornerRadius = 8.0f;
    
    self->createButton.layer.borderWidth = 1.0f;
    self->createButton.layer.cornerRadius = 8.0f;

    self->cancelButton.layer.borderWidth = 1.0f;
    self->cancelButton.layer.cornerRadius = 8.0f;

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createUserAction:(id)sender {

    NSString *tmpValue = self->emailTextField.text;
    if (tmpValue == nil || [tmpValue isEqualToString:@""]) {
        [AppDelegate showAlert:@"Email Field Is Required" withTitle:@"Invalid Data"];
        return;
    }
    
    tmpValue = self->confirmEmail.text;
    if (tmpValue == nil || [tmpValue isEqualToString:@""]) {
        [AppDelegate showAlert:@"Confirm Email Field Is Required" withTitle:@"Invalid Data"];
        return;
    }
    
    if(![self->confirmEmail.text isEqualToString:self->emailTextField.text]){
        [AppDelegate showAlert:@"Email and confirm email fields do not match" withTitle:@"Invalid Data"];
        return;
    }
    
    tmpValue = self->passwordTextField.text;
    if (tmpValue == nil || [tmpValue isEqualToString:@""]) {
        [AppDelegate showAlert:@"Password Field Is Required" withTitle:@"Invalid Data"];
        return;
    }

    tmpValue = self->confirmPassword.text;
    if (tmpValue == nil || [tmpValue isEqualToString:@""]) {
        [AppDelegate showAlert:@"Confirm Password Field Is Required" withTitle:@"Invalid Data"];
        return;
    }

    if(![self->confirmPassword.text isEqualToString:self->passwordTextField.text]){
        [AppDelegate showAlert:@"Email and confirm password fields do not match" withTitle:@"Invalid Data"];
        return;
    }

    tmpValue = self->siteIdTextField.text;
    if (tmpValue == nil || [tmpValue isEqualToString:@""]) {
        [AppDelegate showAlert:@"Site ID Field Is Required" withTitle:@"Invalid Data"];
        return;
    }

    DatabaseManager *databaseManager = [DatabaseManager getSharedIntance];
    
    id user = [databaseManager findWithCondition:[NSString stringWithFormat:@"email = '%@'",self->emailTextField.text ]forModel:[User class]];
    
    if (user != nil){
        [AppDelegate showAlert:@"The supplied email already exists" withTitle:@"Invalid Data"];
        return;
    }
    
    User *tmpUser = [[User alloc] init];
    tmpUser.email = self->emailTextField.text;
    tmpUser.password = [User getEncryptedPasswordFor:self->passwordTextField.text];
    tmpUser.siteId = self->siteIdTextField.text;
    tmpUser.createdAt = [[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]];
    [databaseManager save:tmpUser];
    
    
    [self dismissViewControllerAnimated:true completion:nil];

}

- (IBAction)cancelDialogAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
