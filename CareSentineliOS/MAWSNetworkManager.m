//
//  MAWSNetworkManager.m
//  CareSentineliOS
//
//  Created by Mike on 6/26/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "MAWSNetworkManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation MAWSNetworkManager{
}

static NSString *baseUrl;

+(NSString *)getBaseUrl{
    if (baseUrl == nil) {
        baseUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BaseServicesURL"];
    }
    
    return baseUrl;
}

+(void)callAsyncService:(NSString *)service with:(NSDictionary *)properties method:(NSString *)method onCompletion:(void(^)(AFHTTPRequestOperation *operation, id responseObject))callback onFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *responseObject))error_callback{
    NSString *url = [NSString stringWithFormat:@"%@%@",[MAWSNetworkManager getBaseUrl],service];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if ([method isEqualToString:@"POST"]) {
        [manager POST:url parameters:properties success:callback failure:error_callback];
    }
    else{
        [manager GET:url parameters:properties success:callback failure:error_callback];
    }

}
@end
