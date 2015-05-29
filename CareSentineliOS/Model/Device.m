//
//  Device.m
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Device.h"

@interface Device()
@end


@implementation Device

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"site_id":@"siteId",
             @"created_at":@"createdAt"
             };
}

+(NSString *)getTableName{
    return @"devices";
}


@end
