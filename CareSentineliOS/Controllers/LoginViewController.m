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

@interface LoginViewController () <UITextFieldDelegate>{
    
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
    
    self->emailTextField.delegate = self;
    self->passwordTextField.delegate = self;
    self->clientIdTextField.delegate = self;
    self->siteIdTextField.delegate = self;
    
    //CGColorRef buttonColor = [[UIColor colorWithRed:0.24 green:0.7 blue:(0.62) alpha:1]CGColor];
    self->loginButton.layer.borderWidth = 1.0f;
    self->loginButton.layer.cornerRadius = 8.0f;
    self->loginButton.layer.borderColor = buttonBorderColor;
    
    self->noCloudButton.layer.borderWidth = 1.0f;
    self->noCloudButton.layer.cornerRadius = 8.0f;
    self->noCloudButton.layer.borderColor = buttonBorderColor;


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)doLogin{
    
    NSString *tmpValue = self->emailTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Email Field Is Required" withTitle:@"Invalid Data"];
        return false;
    }
    
    
    tmpValue = self->passwordTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Password Field Is Required" withTitle:@"Invalid Data"];
        return false;
    }
    
    tmpValue = self->siteIdTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Site Id Field Is Required" withTitle:@"Invalid Data"];
        return false;
    }
    
    tmpValue = self->clientIdTextField.text;
    if(tmpValue == nil || [tmpValue isEqualToString:@""]){
        [AppDelegate showAlert:@"The Customer Id Field Is Required" withTitle:@"Invalid Data"];
        return false;
    }
    
    DatabaseManager *dbManager = [DatabaseManager getSharedIntance];
    dbManager.keepConnection = true;
    User *user = (User *)[dbManager findWithCondition:[NSString stringWithFormat:@"email = '%@'",self->emailTextField.text] forModel:[User class]];
    
    if (user == nil) {
        [AppDelegate showAlert:@"This user does not exists" withTitle:@"Invalid Data"];
        [dbManager close];
        return false;
    }
    
    if(![user.password isEqualToString:[User getEncryptedPasswordFor:self->passwordTextField.text]]){
        [AppDelegate showAlert:@"Invalid Password Provided" withTitle:@"Invalid Data"];
        [dbManager close];
        return false;

    }
    
    [dbManager close];
    
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
