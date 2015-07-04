//
//  NewUserViewController.h
//  CareSentineliOS
//
//  Created by Mike on 5/26/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNDialogCompleteDelegate.h"

@interface NewUserViewController : UIViewController
    @property (nonatomic,weak) id<LNDialogCompleteDelegate> dialogCompleteDelegate;
@end
