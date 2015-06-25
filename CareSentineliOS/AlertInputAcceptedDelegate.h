//
//  AlertInputAcceptedDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 6/18/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AlertInputAcceptedDelegate
-(void)input:(NSString *)input AcceptedWithObject:(id)target;
-(void)declinedWithObject:(id)target;
@end
