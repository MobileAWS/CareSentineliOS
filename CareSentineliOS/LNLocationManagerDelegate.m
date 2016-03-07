//
//  LNLocationManagerDelegate.m
//  CareSentineliOS
//
//  Created by Mike on 2/5/16.
//  Copyright © 2016 MobileAWS. All rights reserved.
//

#import "LNLocationManagerDelegate.h"
#import "AppDelegate.h"

@implementation LNLocationManagerDelegate

static void(^currentCallBack)(NSDictionary *data, CLLocation *location);
static NSDictionary *currentData;

-(void)requestLocationWithData:(NSDictionary *)data andCallBack:(void(^)(NSDictionary *data, CLLocation *location))callback{
    AppDelegate *application = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        callback(data, nil);
        return;
    }
    currentData = data;
    currentCallBack = callback;
    [application.locationManager requestLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (currentCallBack && currentData) {
        CLLocation *location = [locations lastObject];
        currentCallBack(currentData,location);
        currentData = nil;
        currentCallBack = nil;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error{
    if(error.code == kCLErrorLocationUnknown){
        if (currentCallBack && currentData) {
            currentCallBack(currentData,nil);
            currentData = nil;
            currentCallBack = nil;
        }
    }
}

@end
