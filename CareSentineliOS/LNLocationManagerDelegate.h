//
//  LNLocationManagerDelegate.h
//  CareSentineliOS
//
//  Created by Mike on 2/5/16.
//  Copyright © 2016 MobileAWS. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface LNLocationManagerDelegate : NSObject <CLLocationManagerDelegate>
-(void)requestLocationWithData:(NSDictionary *)data andCallBack:(void(^)(NSDictionary *data, CLLocation *location))callback;
@end
