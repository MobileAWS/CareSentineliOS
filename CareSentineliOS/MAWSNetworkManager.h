//
//  MAWSNetworkManager.h
//  CareSentineliOS
//
//  Created by Mike on 6/26/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface MAWSNetworkManager : NSObject
+(void)callAsyncService:(NSString *)service with:(NSDictionary *)properties method:(NSString *)method onCompletion:(void(^)(AFHTTPRequestOperation *operation, id responseObject))callback onFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *responseObject))error_callback;

+(void)callAsyncTokenService:(NSString *)service withAction:(NSString *)action with:(NSDictionary *)properties method:(NSString *)method onCompletion:(void(^)(AFHTTPRequestOperation *operation, id responseObject))callback onFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *responseObject))error_callback;

@end
