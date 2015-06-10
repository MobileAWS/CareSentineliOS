//
//  Site.h
//  CareSentineliOS
//
//  Created by Mike on 5/29/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Site : NSObject <BaseModel>
@property NSNumber *id;
@property NSString *siteId;
+(NSDictionary *)getPropertiesMapping;
+(NSString *)getTableName;
@end
