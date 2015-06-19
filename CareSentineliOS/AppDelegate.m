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

@interface AppDelegate ()

@end

@implementation AppDelegate


+(void)showAlert:(NSString *)alert withTitle:(NSString *)title{
    UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:title message:alert delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [dialog show];
    dialog = nil;    
}

+(void)showInputWith:(NSString *)alert title:(NSString *)title defaultText:(NSString *)text delegate:(id)delegate {
    UIAlertView *inputDialog = [[UIAlertView alloc]initWithTitle:title message:alert delegate:delegate cancelButtonTitle:@"Ignore" otherButtonTitles:@"Add", nil];
    
    inputDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    [inputDialog textFieldAtIndex:0].text = text;
    [inputDialog show];
    inputDialog = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIResources initResources];
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
    self.currentCustomer = nil;
    self.currentSite = nil;
    self.currentUser = nil;
    UIViewController *mainViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController dismissViewControllerAnimated:false completion:^{
        appDelegate.window.rootViewController = mainViewController;
        [appDelegate.window makeKeyAndVisible];
    }];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
}

+(void)showLoadingMask{
    [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

+(void)hideLoadingMask{
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

@end
