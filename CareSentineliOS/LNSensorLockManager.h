//
//  LNSensorLockManager.h
//  CareSentineliOS
//
//  Created by Mike on 2/8/16.
//  Copyright © 2016 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LNSensorLockManager : NSObject
-(void)lockNotificationsForSensor:(NSString *)sensorKey;
-(BOOL)isSensorLocked:(NSString *)sensorKey;
@end
