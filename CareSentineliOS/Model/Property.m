//
//  Property.m
//  CareSentineliOS
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Property.h"

@implementation Property


+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"name":@"name",
             @"units":@"units"
             };
}

+(NSString *)getTableName{
    return @"properties";
}

@end
