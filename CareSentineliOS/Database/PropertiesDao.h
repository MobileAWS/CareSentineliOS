//
//  PropertiesDao.h
//  CareSentineliOS
//
//  Created by Mike on 6/11/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"

@interface PropertiesDao : NSObject
+(void)saveProperty:(NSString *)name forDevice:(Device *)device withValue:(NSString *)value;
+(NSMutableArray *)listPropertiesForUser:(NSNumber *) userId;
@end
