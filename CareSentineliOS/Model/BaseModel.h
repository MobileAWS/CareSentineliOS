//
//  BaseModel.h
//  CareSentineliOS
//
//  Created by Mike on 5/25/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

@protocol BaseModel
+(NSDictionary *)getPropertiesMapping;
+(NSString *)getTableName;
@end