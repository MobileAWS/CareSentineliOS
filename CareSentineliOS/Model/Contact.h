//
//  Contact.h
//  CareSentineliOS
//
//  Created by Andres Prada on 12/15/15.
//  Copyright © 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Contact : NSObject <BaseModel>

+(NSString *)getTableName;
+(NSDictionary *)getPropertiesMapping;

@property NSNumber *id;
@property NSString *name;
@property NSString *number;

@end
