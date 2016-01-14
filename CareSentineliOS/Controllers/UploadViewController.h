//
//  UploadViewController.h
//  CareSentineliOS
//
//  Created by Mike on 5/13/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNServerActionButtonDelegate.h"

@interface UploadViewController : UIViewController <LNServerActionButtonDelegate>
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)sendDataAction:(id)sender;
@end
