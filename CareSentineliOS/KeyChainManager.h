//
//  KeyChainManager.h
//  CareSentineliOS
//
//  Created by Mike on 6/22/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainManager : NSObject
+(void)savePassword:(NSString *)value forAccount:(NSString *)account;
+(NSString *)getPasswordForAccount:(NSString *)account;
+(void)removePasswordForAccount:(NSString *)account;
@end
