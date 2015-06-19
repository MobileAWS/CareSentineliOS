//
//  InputAlertViewDelegate.m
//  CareSentineliOS
//
//  Created by Mike on 6/18/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "InputAlertViewDelegate.h"

@implementation InputAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField * textField = [alertView textFieldAtIndex:0];
        [self.delegate input:textField.text AcceptedWithObject:self];
    }
}
@end
