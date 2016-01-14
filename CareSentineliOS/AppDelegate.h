//
//  AppDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 5/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APBLEInterface.h"
#import "LNSwitchChangedDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) NSMutableArray* devicesData;
@property (strong,nonatomic) NSMutableArray* ignoredDevices;
@property (weak,nonatomic) APBLEInterface *bleInterface;
@property (weak) id<LNSwitchChangedDelegate> switchChangedDelegate;
@property BOOL automaticStart;
@property BOOL demoMode;



-(void)logout:(UIButton *)sender withConstraint:(NSLayoutConstraint *)constraint;
-(void) showLogin:(UIViewController *)target;
+(void)showAlert:(NSString *)alert withTitle:(NSString *)title;
+(void)showInputWith:(NSString *)alert title:(NSString *)title defaultText:(NSString *)text delegate:(id)delegate cancelText:(NSString *)cancelText acceptText:(NSString *)acceptText;
+(void)showLoadingMask;
+(void)showLoadingMaskWith:(NSString *)text;
+(void)showConfirmWith:(NSString *)alert title:(NSString *)title target:(id)target callback:(void (^)(void))callback;
+(void)hideLoadingMask;
+(UIView *)findSuperView:(UIView *) target with:(Class)clazz;
+(UIViewController *)findSuperConstroller:(UIViewController *) target with:(Class)clazz;
+(Boolean) checkLogoutWithButton:(UIButton *)button withConstraint:(NSLayoutConstraint *)constraint;
@end

