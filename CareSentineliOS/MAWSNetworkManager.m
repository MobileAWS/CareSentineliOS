//
//  MAWSNetworkManager.m
//  CareSentineliOS
//
//  Created by Mike on 6/26/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "MAWSNetworkManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSString+NSHash.h"

@implementation MAWSNetworkManager{
}

static NSString *baseUrl;

static NSString *envrionment;

+(NSString *)getBaseUrl{
    if (baseUrl == nil) {
        baseUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BaseServicesURL"];
        NSLog(@"%@",baseUrl);
    }
    
    return baseUrl;
}

+(NSString *)getEnvironment{
    if (envrionment == nil) {
        envrionment = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Environment"];
        NSLog(@"%@",envrionment);
    }
    
    return envrionment;
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

+(void)callAsyncTokenService:(NSString *)service withAction:(NSString *)action with:(NSDictionary *)properties method:(NSString *)method onCompletion:(void(^)(AFHTTPRequestOperation *operation, id responseObject))callback onFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *responseObject))error_callback{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[MAWSNetworkManager getBaseUrl]]];
    NSDate *now = [NSDate date];
    NSString *token = [NSString  stringWithFormat:@"{\"environment\":\"%@\",\"action\":\"%@\",\"timestamp\":\"%f\"}", [MAWSNetworkManager getEnvironment], action, [now timeIntervalSince1970]];
    [manager.requestSerializer setValue:[token MD5] forHTTPHeaderField:@"APP_TOKEN"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%f",[now timeIntervalSince1970]] forHTTPHeaderField:@"APP_TIMESTAMP"];    
    if ([method isEqualToString:@"POST"]) {
        [manager POST:service parameters:properties success:callback failure:error_callback];
    }
    else{
        [manager GET:service parameters:properties success:callback failure:error_callback];
    }
    
}

@end
