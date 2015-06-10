//
//  Customer.m
//  CareSentineliOS
//
//  Created by Mike on 5/29/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "Customer.h"

@implementation Customer

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id":@"id",
             @"customer_id":@"customerId"
             };
}

+(NSString *)getTableName{
    return @"customers";
}

@end
