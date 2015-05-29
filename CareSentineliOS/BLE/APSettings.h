//
//  APSettings.h
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 4/5/13.
//  Copyright (c) 2013 AppPotential, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSettings : NSObject
+ (NSArray *)loadDevicesArray;
+ (NSArray *)loadIgnoredArray;

// ------------------------------------------------------------------

+ (BOOL)saveDevicesArray:(NSArray *)devicesArray;
+ (BOOL)saveIgnoredArray:(NSArray *)ignoredArray;
@end
