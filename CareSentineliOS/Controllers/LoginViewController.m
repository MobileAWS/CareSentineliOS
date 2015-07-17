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
#import "Site.h"
#import "Customer.h"
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
    [self->emailTextField setTintColor:[UIColor whiteColor]];
     
    self->passwordTextField.delegate = self;
    [self->passwordTextField setTintColor:[UIColor whiteColor]];
    
    self->clientIdTextField.delegate = self;
    [self->clientIdTextField setTintColor:[UIColor whiteColor]];
    
    self->siteIdTextField.delegate = self;
    [self->siteIdTextField setTintColor:[UIColor whiteColor]];
    
    //CGColorRef buttonColor = [[UIColor colorWithRed:0.24 green:0.7 blue:(0.62) alpha:1]CGColor];
    self->loginButton.layer.borderWidth = 1.0f;
    self->loginButton.layer.cornerRadius = 8.0f;
    self->loginButton.layer.borderColor = buttonBorderColor;
    
    self->noCloudButton.layer.borderWidth = 1.0f;
    self->noCloudButton.layer.cornerRadius = 8.0f;
    self->noCloudButton.layer.borderColor = buttonBorderColor;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tmp = [defaults objectForKey:@"email"];
    if (tmp != nil){
        self->emailTextField.text = tmp;
        tmp = [KeyChainManager getPasswordForAccount:@"maws-loon-password"];
        if (tmp != nil){
            self->passwordTextField.text = tmp;
        }
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

- (IBAction)loginNoCloud:(id)sender {
    [self doLogin:false];
}

- (IBAction)loginCloud:(id)sender {
    [self doLogin:true];
}


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
    
    if (cloudCheck) {
        [AppDelegate showLoadingMaskWith:@"Logging In"];
        [LNNetworkManager loginWithServer:self->emailTextField.text withPassword:self->passwordTextField.text forSite:self->siteIdTextField.text andCustomer:self->clientIdTextField.text onSucess:^(void){
            [AppDelegate hideLoadingMask];
            [self doLocalLogin:true];
        } onFailure:^(NSError *error) {
            [AppDelegate hideLoadingMask];
            [AppDelegate showAlert:error.localizedDescription withTitle:@"Login Error"];
            NSLog(@"%@",error);
        }];
    }
    else{
        [self doLocalLogin:false];
    }

    return;
}

-(void)doLocalLogin:(BOOL)cloudChecked{
    
    DatabaseManager *dbManager = [DatabaseManager getSharedIntance];
    dbManager.keepConnection = true;
    User *user = (User *)[dbManager findWithCondition:[NSString stringWithFormat:@"email = '%@'",self->emailTextField.text] forModel:[User class]];
    
    if (user == nil) {
        if (!cloudChecked){
            [AppDelegate showAlert:@"This user does not exists" withTitle:@"Invalid Data"];
            [dbManager close];
            return;
        }
        else{
            /** If the user exists remotely, but not locally, we create it. This helps recovering
              *  your username if you change devices, for example.
              */
            User *tmpUser = [[User alloc] init];
            tmpUser.email = self->emailTextField.text;
            tmpUser.password = [User getEncryptedPasswordFor:self->passwordTextField.text];
            tmpUser.createdAt = [[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]];
            [dbManager save:tmpUser];
            user = tmpUser;
            tmpUser = nil;
        }
        
    }
    
    if(![user.password isEqualToString:[User getEncryptedPasswordFor:self->passwordTextField.text]]){
        [AppDelegate showAlert:@"Invalid Password Provided" withTitle:@"Invalid Data"];
        [dbManager close];
        return;
        
    }
    

    Site *site = (Site *)[dbManager findWithCondition:[NSString stringWithFormat:@"site_id = '%@'",self->siteIdTextField.text] forModel:[Site class]];

   
    BOOL createRelationship = false;
    
    if (site != nil) {
        /** Look for the user site relationship, if there's none, create it */
        NSInteger count = [dbManager countWithQuery:[NSString stringWithFormat:@"FROM user_sites WHERE user_id = %@ AND site_id = %@",user.id,site.id ]];
        if(count <= 0){
            createRelationship = true;
        }
    }
    else{
        site = [[Site alloc] init];
        site.siteId = self->siteIdTextField.text;
        site = (Site *)[dbManager save:site];
        createRelationship = true;
    }
    
    if (createRelationship) {
        [dbManager insert:[NSString stringWithFormat:@"INSERT INTO user_sites(user_id,site_id) values(%@,%@)",user.id,site.id]];
    }
        
    
    Customer *customer = (Customer *)[dbManager findWithCondition:[NSString stringWithFormat:@"customer_id = '%@'",self->clientIdTextField.text] forModel:[Customer class]];

    
    createRelationship = false;
    
    if (customer != nil) {
        /** Look for the user customer relationship, if there's none, create it */
        NSInteger count = [dbManager countWithQuery:[NSString stringWithFormat:@"FROM user_customers WHERE user_id = %@ AND customer_id = %@",user.id,customer.id ]];
        if(count <= 0){
            createRelationship = true;
        }
    }
    else{
        customer = [[Customer alloc] init];
        customer.customerId = self->clientIdTextField.text;
        customer = (Customer *)[dbManager save:customer];
        createRelationship = true;
    }
    
    if (createRelationship) {
        [dbManager insert:[NSString stringWithFormat:@"INSERT INTO user_customers(user_id,customer_id) values(%@,%@)",user.id,customer.id]];
    }
    
    [dbManager close];
    
    AppDelegate *application = (AppDelegate *)[UIApplication sharedApplication].delegate;
    application.currentUser = user;
    application.currentSite = site;
    application.currentCustomer = customer;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user.email forKey:@"email"];
    [defaults setObject:site.siteId forKey:@"siteId"];
    [defaults setObject:customer.customerId forKey:@"customerId"];
    [KeyChainManager savePassword:passwordTextField.text forAccount:@"maws-loon-password"];
    [self performSegueWithIdentifier:@"MainTabsSegueIdentifier" sender:self->loginButton];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ShowNewUserDialogSegue"]){
        ((NewUserViewController *)segue.destinationViewController).dialogCompleteDelegate = self;
    }
}

-(void)completedDialogWith:(id)targetData{
    if (targetData == nil){
        return;
    }
    User *targetUser = (User *)targetData;
    self->emailTextField.text = targetUser.email;
    self->passwordTextField.text = targetUser.password;
    self->siteIdTextField.text = @"";
    self->clientIdTextField.text = @"";
    
}


-(IBAction)forgotPassword:(id)sender{
    NSString *email = self->emailTextField.text;
    email = email == nil ? @"" : email;
    self->forgotPasswordDelegate = [[InputAlertViewDelegate alloc] init];
    self->forgotPasswordDelegate.delegate = self;
    [AppDelegate showInputWith:@"Enter your email address:" title:NSLocalizedString(@"fuck.you", nil) defaultText:email delegate:self->forgotPasswordDelegate cancelText:@"Cancel" acceptText:@"Ok"];
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

@end
