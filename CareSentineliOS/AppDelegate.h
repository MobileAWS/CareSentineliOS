//
//  AppDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 5/7/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)logout;
+(void)showAlert:(NSString *)alert withTitle:(NSString *)title;
@end

