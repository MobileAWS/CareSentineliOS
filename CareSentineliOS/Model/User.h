//
//  User.h
//  CareSentineliOS
//
//  Created by Mike on 5/27/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface User : NSObject <BaseModel>
@property NSString *email;
@property NSString *siteId;
@property NSString *customerId;
@property NSString *password;
@property NSNumber *createdAt;
+(NSDictionary *)getPropertiesMapping;
+(NSString *)getTableName;
+(NSString *)getEncryptedPasswordFor:(NSString *)password;
@end
