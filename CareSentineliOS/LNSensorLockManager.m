//
//  LNSensorLockManager.m
//  CareSentineliOS
//
//  Created by Mike on 2/8/16.
//  Copyright © 2016 MobileAWS. All rights reserved.
//

#import "LNSensorLockManager.h"

@implementation LNSensorLockManager{
    NSMutableDictionary *currentTimers;
}

-(id)init{
    if (self = [super init]) {
        self->currentTimers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)lockNotificationsForSensor:(NSString *)sensorKey{
    @synchronized(self) {
        if (self->currentTimers[sensorKey] != nil) {
            return;
        }
        NSTimer *sensorTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerForSensorExpired:) userInfo:sensorKey repeats:false];
        self->currentTimers[sensorKey] = sensorTimer;
    }
}

-(void)timerForSensorExpired:(NSTimer *)timer{
    @synchronized(self) {
        NSString *sensorKey = timer.userInfo;
        [self->currentTimers removeObjectForKey:sensorKey];
    }
}

-(BOOL)isSensorLocked:(NSString *)sensorKey{
    BOOL result = false;
    @synchronized(self) {
        result = currentTimers[sensorKey] != nil;
    }
    return result;
}
@end
