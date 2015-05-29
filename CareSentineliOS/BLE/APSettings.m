//
//  APSettings.m
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 4/5/13.
//  Copyright (c) 2013 AppPotential, LLC. All rights reserved.
//

#import "APSettings.h"
#import "APBLEDevice.h"
#import "Constants.h"

@implementation APSettings

// --------------------------------------------------------------------------------
#pragma mark - Load Class Methods
// --------------------------------------------------------------------------------
#define userDefaults                [NSUserDefaults standardUserDefaults]

#define kSettingsDevicesArrayKey     @"DevicesArray"
#define kSettingsDevicesArrayDefault nil
#define kSettingsIgnoredArrayKey     @"IgnoredArray"
#define kSettingsIgnoredArrayDefault nil
#define kSettingsMasterBackground    @"masterBackground"

+ (NSArray *)loadDevicesArray {
    NSArray *devicesArray = [userDefaults objectForKey:kSettingsDevicesArrayKey];
    if (devicesArray)
        return [APBLEDevice devicesArrayFromPropertyListArray:devicesArray];
    else
        return kSettingsDevicesArrayDefault;
}

+ (NSArray *)loadIgnoredArray {
    NSArray *ignoredArray = [userDefaults objectForKey:kSettingsIgnoredArrayKey];
    if (ignoredArray)
        return [APBLEDevice devicesArrayFromPropertyListArray:ignoredArray];
    else
        return kSettingsIgnoredArrayDefault;
}

+ (NSString *)backgroundImageFilename {
    NSString *backgroundImageFilename = [userDefaults objectForKey:kSettingsMasterBackground];
    if (backgroundImageFilename)
        return backgroundImageFilename;
    else
        return kImageBackgroundDefaultTitle;
}

// --------------------------------------------------------------------------------
#pragma mark - Save Class Methods
// --------------------------------------------------------------------------------
+ (BOOL)saveDevicesArray:(NSArray *)devicesArray {
    NSArray *propertyListArray = [APBLEDevice propertyListArrayFromDevicesArray:devicesArray];
    [userDefaults setObject:propertyListArray forKey:kSettingsDevicesArrayKey];
    return [userDefaults synchronize];
}

+ (BOOL)saveIgnoredArray:(NSArray *)ignoredArray {
    NSArray *propertyListArray = [APBLEDevice propertyListArrayFromDevicesArray:ignoredArray];
    [userDefaults setObject:propertyListArray forKey:kSettingsIgnoredArrayKey];
    return [userDefaults synchronize];
}

+ (BOOL)saveBackgroundImageFilename:(NSString *)backgroundImageFilename {
    // -- Set the setting values
    [userDefaults setObject:backgroundImageFilename forKey:kSettingsMasterBackground];
    return [userDefaults synchronize];
}
@end
