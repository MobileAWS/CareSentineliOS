//
//  Device.h
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Device : NSObject <BaseModel>
    +(NSString *)getTableName;
    +(NSDictionary *)getPropertiesMapping;
    @property NSNumber *id;
    @property NSString *name;
    @property NSNumber *siteId;
    @property NSNumber *createdAt;
@end
