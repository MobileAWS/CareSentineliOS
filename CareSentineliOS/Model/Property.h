//
//  Property.h
//  CareSentineliOS
//
//  Created by Mike on 6/10/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Property : NSObject <BaseModel>
    @property NSNumber *id;
    @property NSString *name;
    @property NSString *units;
@end
