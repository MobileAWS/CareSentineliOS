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
-(id<BaseModel>)save:(id<BaseModel>)data;
-(id)findById:(NSNumber *)targetId;
-(id)findWithCondition:(NSString *)condition forModel:(Class)targetClass;
-(NSMutableArray *)listWithModel:(Class)model condition:(NSString *)condition;
-(NSMutableArray *)listWithModel:(Class)model forQuery:(NSString *)query;
-(NSInteger)countWithQuery:(NSString *)query;
-(void)insert:(NSString *)insertQuery;
-(void)update:(NSString *)updateQuery;
-(void)close;
-(void)delete:(NSString *)deleteQuery;
@property BOOL keepConnection;
@end
