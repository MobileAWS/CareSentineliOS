//
//  User.m
//  CareSentineliOS
//
//  Created by Mike on 5/27/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "User.h"
#import "BaseModel.h"

@implementation User

+(NSDictionary *)getPropertiesMapping{
    return @{@"email":@"email",
             @"site_id":@"siteId",
             @"password":@"password",
             @"customer_id":@"customerId",
             @"created_at":@"createdAt"
             };
}

+(NSString *)getTableName{
    return @"users";
}

+(NSString *)getEncryptedPasswordFor:(NSString *)password{
    return password;
}

@end
