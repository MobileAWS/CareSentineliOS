//
//  DeviceProperty.h
//  CareSentineliOS
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface DeviceProperty : NSObject <BaseModel>
@property NSNumber *id;
@property NSNumber *propertyId;
@property NSNumber *deviceId;
@property NSString *value;
@property NSNumber *createdAt;
@property NSNumber *dismissedAt;
@end
