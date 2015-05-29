//
//  DatabaseManager.h
//  CareSentineliOS
//
//  Created by Mike on 5/20/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface DatabaseManager : NSObject
+(DatabaseManager *)getSharedIntance;
-(BOOL)save:(id<BaseModel>)data;
-(id)findById:(NSNumber *)targetId;
-(id)findWithCondition:(NSString *)condition forModel:(Class)targetClass;
-(NSArray *)listWithModel:(Class)model condition:(NSString *)condition;
@end
