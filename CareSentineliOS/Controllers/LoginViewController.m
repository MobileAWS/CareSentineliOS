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
#import "AppDelegate.h"
#import "UIResources.h"
#import "MawsTextView.h"
#import "KeyChainManager.h"
#import "LNNetworkManager.h"
#import "NewUserViewController.h"
#import "InputAlertViewDelegate.h"
#import "AlertInputAcceptedDelegate.h"

@interface LoginViewController () <UITextFieldDelegate,AlertInputAcceptedDelegate>{
    
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *clientIdTextField;
    __weak IBOutlet UITextField *siteIdTextField;
    __weak IBOutlet UIButton *noCloudButton;
    __weak IBOutlet UIButton *loginButton;
    InputAlertViewDelegate *forgotPasswordDelegate;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->emailTextField.delegate = self;
    [self->emailTextField setTintColor:baseBackgroundColor];
     
    self->passwordTextField.delegate = self;
    [self->passwordTextField setTintColor:baseBackgroundColor];
    
    self->clientIdTextField.delegate = self;
    [self->clientIdTextField setTintColor:baseBackgroundColor];
    
    self->siteIdTextField.delegate = self;
    [self->siteIdTextField setTintColor:baseBackgroundColor];
    
    //CGColorRef buttonColor = [[UIColor colorWithRed:0.24 green:0.7 blue:(0.62) alpha:1]CGColor];
    self->loginButton.layer.borderWidth = 1.0f;
    self->loginButton.layer.cornerRadius = 8.0f;
    self->loginButton.layer.borderColor = buttonBorderColorRef;
    
    self->noCloudButton.layer.borderWidth = 1.0f;
    self->noCloudButton.layer.cornerRadius = 8.0f;
    self->noCloudButton.layer.borderColor = buttonBorderColorRef;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tmp = [defaults objectForKey:@"email"];
    if (tmp != nil){
        self->emailTextField.text = tmp;
    }
    
    tmp = [defaults objectForKey:@"siteId"];
    if (tmp != nil){
        self->siteIdTextField.text = tmp;
    }
    
    tmp = [defaults objectForKey:@"customerId"];
    if (tmp != nil){
        self->clientIdTextField.text = tmp;
    }
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == emailTextField) {
        [passwordTextField becomeFirstResponder];
        return NO;
    }

    if (textField == passwordTextField) {
        if (siteIdTextField.text != nil && clientIdTextField.text != nil) {
            [self.view endEditing:YES];
            return NO;
        }
        [siteIdTextField becomeFirstResponder];
        return NO;
    }
    
    if (textField == siteIdTextField) {
        [clientIdTextField becomeFirstResponder];
        return NO;
    }
    
    if (textField == clientIdTextField) {
        [passwordTextField becomeFirstResponder];
        [self.view endEditing:YES];
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginCloud:(id)sender {
    [self doLogin:true];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(void)doLogin:(BOOL)cloudCheck{
    
    NSString *tmpValue = self->emailTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Email Field Is Required" withTitle:@"Invalid Data"];
        return;
    }
    
    
    tmpValue = self->passwordTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Password Field Is Required" withTitle:@"Invalid Data"];
        return;
    }
    
    tmpValue = self->siteIdTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Site Id Field Is Required" withTitle:@"Invalid Data"];
        return;
    }
    
    tmpValue = self->clientIdTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Customer Id Field Is Required" withTitle:@"Invalid Data"];
        return;
    }
    
    [AppDelegate showLoadingMaskWith:@"Loging In"];
    [LNNetworkManager loginWithServer:self->emailTextField.text withPassword:self->passwordTextField.text forSite:self->siteIdTextField.text andCustomer:self->clientIdTextField.text onSucess:^(void){
        
            NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
            [preferences setValue:self->emailTextField.text forKey:@"email"];
            [preferences setValue:self->siteIdTextField.text forKey:@"siteId"];
            [preferences setValue:self->clientIdTextField.text forKey:@"customerId"];
            [preferences synchronize];
        
            [AppDelegate hideLoadingMask];
            [self dismissViewControllerAnimated:true completion:nil];
            if (self.callerController) {
                SEL loginSucessfull = @selector(loginSucessfull);
                if ([self.callerController respondsToSelector:loginSucessfull]) {
                    [self.callerController performSelector:loginSucessfull];
                }
            }
        } onFailure:^(NSError *error) {
            [AppDelegate hideLoadingMask];
            [AppDelegate showAlert:error.localizedDescription withTitle:@"Login Error"];
            NSLog(@"%@",error);
        }];
    
    
    return;
}
#pragma clang diagnostic pop

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ShowNewUserDialogSegue"]){
        ((NewUserViewController *)segue.destinationViewController).dialogCompleteDelegate = self;
    }
}

-(void)completedDialogWith:(id)targetData{
    if (targetData == nil){
        return;
    }
    self->passwordTextField.text = @"";
    self->siteIdTextField.text = @"";
    self->clientIdTextField.text = @"";
}

-(IBAction)forgotPassword:(id)sender{
    NSString *email = self->emailTextField.text;
    email = email == nil ? @"" : email;
    self->forgotPasswordDelegate = [[InputAlertViewDelegate alloc] init];
    self->forgotPasswordDelegate.delegate = self;
    [AppDelegate showInputWith:@"Enter your email address:" title:NSLocalizedString(@"Change your password", nil) defaultText:email delegate:self->forgotPasswordDelegate cancelText:@"Cancel" acceptText:@"Ok"];
}

-(void)input:(NSString *)input AcceptedWithObject:(id)target{
    self->forgotPasswordDelegate = nil;
    [AppDelegate showLoadingMaskWith:@"Sending Instructions"];
    [LNNetworkManager resetPasswordFor:input onSucess:^{
        [AppDelegate hideLoadingMask];
        [AppDelegate showAlert:[NSString stringWithFormat:@"An email was sent to %@ with instructions to reset your password",input] withTitle:@"Reset Instructions Sent"];
    } onFailure:^(NSError *error) {
        [AppDelegate hideLoadingMask];
        [AppDelegate showAlert:[NSString stringWithFormat:@"An error occurred: %@",error.description] withTitle:@"Reset Instructions Sent"];
    }];
}

-(void)declinedWithObject:(id)target{
    self->forgotPasswordDelegate = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goBackAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
