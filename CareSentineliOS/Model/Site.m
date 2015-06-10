//
//  Site.m
//  CareSentineliOS
//
//  Created by Mike on 5/29/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Site.h"

@implementation Site

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"site_id":@"siteId"
             };
}

+(NSString *)getTableName{
    return @"sites";
}

@end
