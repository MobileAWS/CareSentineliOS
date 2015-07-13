//
//  AppDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 5/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Site.h"
#import "User.h"
#import "Customer.h"
#import "APBLEInterface.h"
#import "LNSwitchChangedDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) Site *currentSite;
@property (strong,nonatomic) User *currentUser;
@property (strong,nonatomic) Customer *currentCustomer;
@property (strong,nonatomic) NSMutableArray* devicesData;
@property (strong,nonatomic) NSMutableArray* ignoredDevices;
@property (weak,nonatomic) APBLEInterface *bleInterface;
@property (weak) id<LNSwitchChangedDelegate> switchChangedDelegate;

-(void)logout;
+(void)showAlert:(NSString *)alert withTitle:(NSString *)title;
+(void)showInputWith:(NSString *)alert title:(NSString *)title defaultText:(NSString *)text delegate:(id)delegate;
+(void)showLoadingMask;
+(void)showLoadingMaskWith:(NSString *)text;
+(void)showConfirmWith:(NSString *)alert title:(NSString *)title target:(id)target callback:(void (^)(void))callback;
+(void)hideLoadingMask;
+(UIView *)findSuperView:(UIView *) target with:(Class)clazz;
+(UIViewController *)findSuperConstroller:(UIViewController *) target with:(Class)clazz;
@end

