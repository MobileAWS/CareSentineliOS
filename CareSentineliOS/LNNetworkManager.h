//
//  LNNetworkManager.h
//  CareSentineliOS
//
//  Created by Mike on 6/29/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface LNNetworkManager : NSObject


+(void)loginWithServer:(NSString *)email withPassword:(NSString *)password forSite:(NSString *)site andCustomer:(NSString *)customer onSucess:(void(^)(void))callback onFailure:(void(^)(NSError *error))failure;

+(void)signupWith:(NSString *)email withPassword:(NSString *)password andConfirmPassword:(NSString *)confirm onSucess:(void(^)(void))callback onFailure:(void(^)(NSError *error))failure;

+(void)uploadData:(NSArray *)devices onSucess:(void(^)(NSMutableArray *success))callback onFailure:(void(^)(NSError *error))failure;

+(void)resetPasswordFor:(NSString *)email onSucess:(void(^)(void))callback onFailure:(void(^)(NSError *error))failure;

+(void)clear;

+(void)sendSms:(NSString *)message toNumbers:(NSArray *)numbers withLocation:(CLLocation *)location onSucess:(void(^)(void))callback onFailure:(void(^)(NSError *error))failure;

+(BOOL)sessionValid;

+(NSString *)getToken;

@end

