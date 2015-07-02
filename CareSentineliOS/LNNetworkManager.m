//
//  LNNetworkManager.m
//  CareSentineliOS
//
//  Created by Mike on 6/29/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "LNNetworkManager.h"
#import "MAWSNetworkManager.h"
#import "PropertiesDao.h"
#import "AppDelegate.h"
#import "DevicePropertyDescriptor.h"

@implementation LNNetworkManager{
}

static NSString *token;

+(BOOL)sessionValid{
    return token != nil;
}

+(void)clear{
    token = nil;
}

+(void)loginWithServer:(NSString *)email withPassword:(NSString *)password forSite:(NSString *)site andCustomer:(NSString *)customer onSucess:(void(^)(void))callback onFailure:(void(^)(NSError *error))failure{
    [MAWSNetworkManager callAsyncService:@"users/login" with:@{@"email":email,@"password":password,@"site_name":site,@"customer_id":customer} method:@"POST" onCompletion:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject != nil){
            NSDictionary *resp = (NSDictionary *)responseObject;
            NSDictionary *iresp = [resp objectForKey:@"response"];
            token = [iresp objectForKey:@"token"];
            callback();
        }
    } onFailure:^(AFHTTPRequestOperation *operation, NSError *responseObject) {
        failure(responseObject);
    }];
}

+(void)signupWith:(NSString *)email withPassword:(NSString *)password andConfirmPassword:(NSString *)confirm onSucess:(void(^)(void))callback onFailure:(void(^)(NSError *error))failure{
    
    [MAWSNetworkManager callAsyncService:@"user/sign_up" with:@{@"email":email,@"password":password,@"confirm_password":confirm,@"role_id":@"caregiver"} method:@"POST" onCompletion:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject != nil){
            callback();
        }
    } onFailure:^(AFHTTPRequestOperation *operation, NSError *responseObject) {
        failure(responseObject);
    }];

}


+(void)uploadData:(NSArray *)devices onSucess:(void(^)(NSMutableArray *success))callback onFailure:(void(^)(NSError *error))failure{
    
    if(token == nil){
        AppDelegate *application = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [LNNetworkManager loginWithServer:application.currentUser.email withPassword:application.currentUser.password forSite:application.currentSite.siteId andCustomer:application.currentCustomer.customerId onSucess:^{
            NSMutableArray *sucessDevices = [[NSMutableArray alloc] init];
            [LNNetworkManager callUploadDevice:devices count:0 onSucess:callback onFailure:failure sucessDevices:sucessDevices];
        } onFailure:^(NSError *error) {
            failure(error);
        }];
    }
    else{
        NSMutableArray *sucessDevices = [[NSMutableArray alloc] init];
        [LNNetworkManager callUploadDevice:devices count:0 onSucess:callback onFailure:failure sucessDevices:sucessDevices];
    }
}

+(void)callUploadDevice:(NSArray *)devices count:(NSInteger)count onSucess:(void(^)(NSMutableArray *success))callback onFailure:(void(^)(NSError *error))failure sucessDevices:(NSMutableArray *)sucessDevices{
    
    Device *device = devices[count];
    NSArray *properties = [PropertiesDao listNotificationsForDevice:device.id];
    NSMutableArray *propertiesData = [[NSMutableArray alloc]init];
    for (int i = 0; i < properties.count; i++) {
        NSDictionary *data = [((DevicePropertyDescriptor *)properties[i]) getRequestData];
        [propertiesData addObject:data];
    }
    if (propertiesData.count <= 0) {
        if (count + 1 >= devices.count){
            callback(sucessDevices);
        }else{
            [LNNetworkManager callUploadDevice:devices count:(count + 1 ) onSucess:callback onFailure:failure sucessDevices:sucessDevices];
        }
        return;
    }

    [MAWSNetworkManager callAsyncService:@"device/addproperties" with:@{@"device":[devices[count] getRequestData],@"token":token,@"properties":propertiesData} method:@"POST" onCompletion:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject != nil){
            [sucessDevices addObject:device.id];
            if (count + 1 >= devices.count){
                    callback(sucessDevices);
            }
            else{
                [LNNetworkManager callUploadDevice:devices count:(count + 1 ) onSucess:callback onFailure:failure sucessDevices:sucessDevices];
            }
            
        }
    } onFailure:^(AFHTTPRequestOperation *operation, NSError *responseObject) {
        failure(responseObject);
    }];
}
@end