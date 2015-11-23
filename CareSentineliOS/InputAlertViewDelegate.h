//
//  InputAlertViewDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 6/18/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertInputAcceptedDelegate.h"

@interface InputAlertViewDelegate : NSObject <UIAlertViewDelegate>
@property BOOL canceled;
@property NSString *textValue;
@property id<AlertInputAcceptedDelegate> delegate;
@property id targetObject;
@property UIButton *okButton;
@end
