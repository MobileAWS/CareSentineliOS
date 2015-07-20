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
    [inputDialog textFieldAtIndex:0].text = text;
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
    [UIResources initResources];
    [LNConstants initConstants];
    // Override point for customization after application launch.
    [[APAppServices alloc] init];
    [TSMessage addCustomDesignFromFileWithName:@"TSLoonMessageDesign.json"];
    
    /** Set the tab bar default appereance */
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    /** Set the navitation bars default styles */
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{ NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]}forState:UIControlStateNormal];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *userNotifcationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifcationSettings];        
    return YES;
}

+(UIView *)findSuperView:(UIView *) target with:(Class)clazz{
    UIView *superView = [target superview];
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView) {
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

- (void) logout{
    [AppDelegate showConfirmWith:@"Are you sure you want to logout?" title:@"Confirm Logout" target:nil callback:^{
        
        self.currentCustomer = nil;
        self.currentSite = nil;
        self.currentUser = nil;
        self.devicesData = nil;
        self.ignoredDevices = nil;
        self.switchChangedDelegate = nil;
        self.bleInterface = nil;
        [LNNetworkManager clear];
        
        
        UIViewController *mainViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.window.rootViewController dismissViewControllerAnimated:false completion:^{
            self.window.rootViewController = mainViewController;
            [self.window makeKeyAndVisible];
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
