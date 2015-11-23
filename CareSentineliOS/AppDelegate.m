//
//  AppDelegate.m
//  CareSentineliOS
//
//  Created by Mike on 5/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "APAppServices.h"
#import "UIResources.h"
#import "MBProgressHUD.h"
#import "TSMessage.h"
#import "InputAlertViewDelegate.h"
#import "MAWSNetworkManager.h"
#import "LNNetworkManager.h"
#import "LNConstants.h"
#import "KeyChainManager.h"
#import "Fabric/Fabric.h"
#import "Crashlytics/Crashlytics.h"

@interface AppDelegate (){
}
@end

@implementation AppDelegate

static void (^currentAlertInvocation) (void);

+(void)showAlert:(NSString *)alert withTitle:(NSString *)title{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:title message:alert delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [dialog show];
    dialog = nil;    
}


+(void)showInputWith:(NSString *)alert title:(NSString *)title defaultText:(NSString *)text delegate:(id)delegate cancelText:(NSString *)cancelText acceptText:(NSString *)acceptText{
    UIAlertView *inputDialog = [[UIAlertView alloc]initWithTitle:title message:alert delegate:delegate cancelButtonTitle:cancelText otherButtonTitles:acceptText, nil];
    inputDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *inputField = [inputDialog textFieldAtIndex:0];
    inputField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [inputDialog show];
    inputDialog = nil;
}

+(void)showConfirmWith:(NSString *)alert title:(NSString *)title target:(id)target callback:(void (^)(void))callback{
    UIAlertView *confirmDialog = [[UIAlertView alloc]initWithTitle:title message:alert delegate:[UIApplication sharedApplication].delegate cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    currentAlertInvocation =  callback;
    [confirmDialog show];
    confirmDialog = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.cancelButtonIndex != buttonIndex){
        currentAlertInvocation();
    }
    currentAlertInvocation = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [Fabric with:@[[Crashlytics class]]];
    
    self.demoMode = false;
    [UIResources initResources];
    [LNConstants initConstants];
    // Override point for customization after application launch.
    [[APAppServices alloc] init];
    [TSMessage addCustomDesignFromFileWithName:@"TSLoonMessageDesign.json"];
    
    /** Set the tab bar default appereance */
    /**[[UITabBar appearance] setTintColor:[UIColor whiteColor]];**/
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }
                                             forState:UIControlStateSelected];
    
    /** Set the navitation bars default styles */
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{ NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]}forState:UIControlStateNormal];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *userNotifcationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifcationSettings];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [userDefaults stringForKey:@"email"];
    NSString *siteId =[userDefaults stringForKey:@"siteId"];
    NSString *customerId =[userDefaults stringForKey:@"customerId"];
    NSString *password;
    if (email != nil) {
        password = [KeyChainManager getPasswordForAccount:email];
    }
    
    self.automaticStart = email != nil && siteId != nil && customerId != nil && password != nil  && password != nil;
    
    self.automaticStart = self.automaticStart ? [AppDelegate doLocalLogin:false withUser:email password:password site:siteId customer:customerId] : false;
    [self.window makeKeyAndVisible];
    if (!self.automaticStart) {
        [self.window.rootViewController presentViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:true completion:nil];
    }
    else{
        [self.window.rootViewController presentViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"MainTabsViewController"] animated:true completion:nil];
    }
    return YES;
}

+(UIView *)findSuperView:(UIView *) target with:(Class)clazz{
    UIView *superView = [target superview];
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView) {
        NSLog(@"%@",superView);
        if ([superView isKindOfClass:clazz]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    
    return superView;
}

+(UIViewController *)findSuperConstroller:(UIViewController *) target with:(Class)clazz{
    UIViewController *superController = [target parentViewController];
    
    while (superController != nil) {
        if ([superController isKindOfClass:clazz]) {
            return superController;
        } else {
            superController = superController.parentViewController;
        }
    }
    return nil;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(BOOL)doLocalLogin:(BOOL)cloudChecked withUser:(NSString *)username password:(NSString *)password site:(NSString *)siteId customer:(NSString *)customerId {
    
    DatabaseManager *dbManager = [DatabaseManager getSharedIntance];
    dbManager.keepConnection = true;
    NSString *usernameValue = [DatabaseManager encodeString:username];
    User *user = (User *)[dbManager findWithCondition:[NSString stringWithFormat:@"email = '%@'",usernameValue] forModel:[User class]];
    
    if (user == nil) {
        if (!cloudChecked){
            [AppDelegate showAlert:@"This user does not exists" withTitle:@"Invalid Data"];
            [dbManager close];
            return false;
        }
        else{
            /** If the user exists remotely, but not locally, we create it. This helps recovering
             *  your username if you change devices, for example.
             */
            User *tmpUser = [[User alloc] init];
            tmpUser.email = username;
            tmpUser.password = [User getEncryptedPasswordFor:password];
            tmpUser.createdAt = [[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]];
            [dbManager save:tmpUser];
            user = tmpUser;
            tmpUser = nil;
        }
        
    }
    
    if(![user.password isEqualToString:[User getEncryptedPasswordFor:password]]){
        if (!cloudChecked) {
            [AppDelegate showAlert:@"Invalid Password Provided" withTitle:@"Invalid Data"];
            [dbManager close];
            return false;
        }
        user.password = password;
        [dbManager save:user];
    }
    
    
    NSString *siteValue = [DatabaseManager encodeString:siteId];
    Site *site = (Site *)[dbManager findWithCondition:[NSString stringWithFormat:@"site_id = '%@'",siteValue] forModel:[Site class]];
    
    
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
        site.siteId = siteId;
        site = (Site *)[dbManager save:site];
        createRelationship = true;
    }
    
    if (createRelationship) {
        [dbManager insert:[NSString stringWithFormat:@"INSERT INTO user_sites(user_id,site_id) values(%@,%@)",user.id,site.id]];
    }
    
    
    NSString *customerValue = [DatabaseManager encodeString:customerId];
    Customer *customer = (Customer *)[dbManager findWithCondition:[NSString stringWithFormat:@"customer_id = '%@'",customerValue] forModel:[Customer class]];
    
    
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
        customer.customerId = customerId;
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
    [KeyChainManager savePassword:password forAccount:user.email];
    
    [CrashlyticsKit setUserIdentifier: [NSString stringWithFormat:@"%@,%@,%@",user.id, site.siteId,customer.customerId]];
    [CrashlyticsKit setUserEmail: user.email];
    [CrashlyticsKit setUserName: user.email];


    return TRUE;
}


- (void) logout{
    [AppDelegate showConfirmWith:@"Are you sure you want to logout?" title:@"Confirm Logout" target:nil callback:^{
        
        NSString *username = self.currentUser.email;
        self.currentCustomer = nil;
        self.currentSite = nil;
        self.currentUser = nil;
        self.devicesData = nil;
        self.ignoredDevices = nil;
        self.switchChangedDelegate = nil;
        self.bleInterface = nil;
        [LNNetworkManager clear];
        
        [KeyChainManager removePasswordForAccount:username];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.window.rootViewController dismissViewControllerAnimated:false completion:^{
            [self.window.rootViewController presentViewController:mainViewController animated:true completion:false];
        }];

    }];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
}

+(void)showLoadingMask{
    [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

+(void)showLoadingMaskWith:(NSString *)text{
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    progress.labelText = text;
}


+(void)hideLoadingMask{
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

@end
