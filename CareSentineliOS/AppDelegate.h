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

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) Site *currentSite;
@property (strong,nonatomic) User *currentUser;
@property (strong,nonatomic) Customer *currentCustomer;
@property (strong,nonatomic) NSMutableArray* devicesData;

-(void)logout;
+(void)showAlert:(NSString *)alert withTitle:(NSString *)title;
+(void)showInputWith:(NSString *)alert title:(NSString *)title defaultText:(NSString *)text delegate:(id)delegate;
+(void)showLoadingMask;
+(void)hideLoadingMask;
@end

