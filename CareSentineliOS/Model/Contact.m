//
//  Contact.m
//  CareSentineliOS
//
//  Created by Andres Prada on 12/15/15.
//  Copyright © 2015 MobileAWS. All rights reserved.
//

#import "Contact.h"
#import "BaseModel.h"

@implementation Contact 

+(NSDictionary *)getPropertiesMapping{
    return @{
             @"id": @"id",
             @"name":@"name",
             @"number":@"number",
             
             };
}
+(NSString *)getTableName{
    return @"contacts";
}

@end
