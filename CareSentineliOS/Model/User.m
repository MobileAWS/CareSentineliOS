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
    return @{@"id":@"id",
             @"email":@"email",
             @"password":@"password",
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