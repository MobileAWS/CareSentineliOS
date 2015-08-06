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
#import "UIResources.h"
#import "LNNetworkManager.h"

@interface NewUserViewController() <UITextFieldDelegate>{
    
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *confirmEmail;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *confirmPassword;
    __weak IBOutlet UIButton *createButton;
    __weak IBOutlet UIButton *cancelButton;
}
@end

@implementation NewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->emailTextField.delegate = self;
    [self->emailTextField setTintColor:[UIColor whiteColor]];
    
    self->confirmEmail.delegate = self;
    [self->confirmEmail setTintColor:[UIColor whiteColor]];
    
    self->passwordTextField.delegate = self;
    [self->passwordTextField setTintColor:[UIColor whiteColor]];
    
    self->confirmPassword.delegate = self;
    [self->confirmPassword setTintColor:[UIColor whiteColor]];
    
    self->createButton.layer.borderWidth = 1.0f;
    self->createButton.layer.cornerRadius = 8.0f;
    self->createButton.layer.borderColor = buttonBorderColor;

    self->cancelButton.layer.borderWidth = 1.0f;
    self->cancelButton.layer.cornerRadius = 8.0f;
    self->cancelButton.layer.borderColor = buttonBorderColor;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (textField == emailTextField) {
        [confirmEmail becomeFirstResponder];
    }

    if (textField == confirmEmail) {
        [passwordTextField becomeFirstResponder];
    }

    
    if (textField == passwordTextField) {
        [confirmPassword becomeFirstResponder];
    }

    
    if (textField == confirmPassword) {
        [self.view endEditing:YES];
    }

    return NO;
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

    DatabaseManager *databaseManager = [DatabaseManager getSharedIntance];
    
    NSString *usernameValue = [DatabaseManager encodeString:self->emailTextField.text];
    id user = [databaseManager findWithCondition:[NSString stringWithFormat:@"email = '%@'",usernameValue ]forModel:[User class]];
    
    if (user != nil){
        [AppDelegate showAlert:@"The supplied email already exists" withTitle:@"Invalid Data"];
        return;
    }
    
    [AppDelegate showLoadingMaskWith:@"Creating User"];
    [LNNetworkManager signupWith:self->emailTextField.text withPassword:self->passwordTextField.text andConfirmPassword:self->confirmPassword.text onSucess:^(void){
        [AppDelegate hideLoadingMask];        
        [self userLocalSignup];
    } onFailure:^(NSError *error) {
        [AppDelegate hideLoadingMask];
        [AppDelegate showAlert:error.localizedDescription withTitle:@"Error Creating User"];
    }];
    
}

-(void)userLocalSignup{
    DatabaseManager *databaseManager = [DatabaseManager getSharedIntance];
    User *tmpUser = [[User alloc] init];
    tmpUser.email = self->emailTextField.text;
    tmpUser.password = [User getEncryptedPasswordFor:self->passwordTextField.text];
    tmpUser.createdAt = [[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]];
    [databaseManager save:tmpUser];
    [self.dialogCompleteDelegate completedDialogWith:tmpUser];
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
