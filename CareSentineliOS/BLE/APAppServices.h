//
//  APAppServices.h
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 10/3/13.
//  Copyright (c) 2013 AppPotential. All rights reserved.
//

#import <Foundation/Foundation.h>

// --------------------------------------------------------------------------------
#pragma mark - Macros
// --------------------------------------------------------------------------------
// -- Debug Flags
#define INFO_MESSAGES 1
//#define DEALLOC_MESSAGES 1
//#define REMOTE_INFO_MESSAGES


// -- Macros
#define RGB(r, g, b)     [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define AND &&
#define OR ||
////#define APLogRemote(message, ...) APServiceLog(@"%@: %@: %@", [self class], NSStringFromSelector(_cmd), [NSString stringWithFormat:message, ##__VA_ARGS__],APLogLevelInformational)
#define APLogErr(error) TFLog(@"%@: %@: %@", [self class], NSStringFromSelector(_cmd), error)
#define APLogErrMsg(message, ...) NSLog(@"%@: %@: %@", [self class], NSStringFromSelector(_cmd), [NSString stringWithFormat:message, ##__VA_ARGS__])
#define APLogLocalErr(error) NSLog(@"%@: %@: %@", [self class], NSStringFromSelector(_cmd), error)
#ifdef INFO_MESSAGES
#define APLog(label, ...) NSLog(label, ## __VA_ARGS__)
#define APMainThreadLog(x) [self performSelectorOnMainThread:@selector(log:) withObject:x waitUntilDone:YES]
#define APBM_START  NSDate *start = [NSDate date];
#define APBM_SNAP   start = [NSDate date];
#define APBM_END(label) {NSDate *end = [NSDate date]; NSLog(@"Elapsed Time for %@: %f", label, [MPTime timeDiff:start endDate:end]);}
#else
#define APLog(label, ...)  // (label, ## __VA_ARGS__)
#define APMainThreadLog(x) // (x)
#define APBM_START         //
#define APBM_SNAP          //
#define APBM_END(label)    // (label)
#endif

#define APLogRect(label, rect) APLog(@"%s: (%f, %f, %f, %f)", #label, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define APLogRect2(label, rect) NSLog(@"%s: (%f, %f, %f, %f)", #label, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define APLogPoint(label, rect) APLog(@"%s: (%f, %f)", #label, rect.x, rect.y)
#define APLogObj(value) APLog(@"--> Value of %s: %@", #value, value)
#define APLogInt(value) APLog(@"--> Value of %s: %d", #value, value)
#define APLogFloat(value) APLog(@"--> Value of %s: %f", #value, value)

#ifdef DEALLOC_MESSAGES
#define APLogDealloc NSLog(@"%DEALLOC:%@:%@", [self class], NSStringFromSelector(_cmd))
#else
#define APLogDealloc //
#endif

#define APAssert(condition, desc, ...) \
if (!(condition)) { \
APLogErr((desc), ## __VA_ARGS__);\
NSAssert((condition), (desc), ## __VA_ARGS__);\
}

#define APAlert(title,msg)	{UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];}

#define CFREL(x) if (x) {CFRelease(x);}

#define EnumToNum(value) [NSNumber numberWithInteger: value]
#define NumToEnum(value) [value integerValue]

#define DEG2RAD(x) (0.0174532925 * (x))

// --------------------------------------------------------------------------------
#pragma mark - Constants
// --------------------------------------------------------------------------------
// -- Images
#define kImageBattery5              @"Battery-5"
#define kImageBattery4              @"Battery-4"
#define kImageBattery3              @"Battery-3"
#define kImageBattery2              @"Battery-2"
#define kImageBattery1              @"Battery-1"
#define kImageDeviceConnected5      @"Connected-5"
#define kImageDeviceConnected4      @"Connected-4"
#define kImageDeviceConnected3      @"Connected-3"
#define kImageDeviceConnected2      @"Connected-2"
#define kImageDeviceConnected1      @"Connected-1"
#define kImageDeviceDisconected     @"Disconnected"
#define kImageButtonChecked         @"Checked"
#define kImageButtonUnchecked       @"Unchecked"
#define kImageAccessoryTypeDiscl    @"Chevron"

@interface APAppServices : NSObject
+ (APAppServices *)appServicesObject;

// --------------------------------------------------------------------------------
#pragma mark - Error Methods
// --------------------------------------------------------------------------------
+ (NSError *)errorObjectWithCode:(NSInteger)code description:(NSString *)description failureReason:(NSString *)reason;

// --------------------------------------------------------------------------------
+ (void)featureNotImplemented:(NSString *)featureName;

// --------------------------------------------------------------------------------
#pragma mark - Version Methods
// --------------------------------------------------------------------------------
+ (float)osVersion;
+ (NSString *)appVersionString;
+ (NSString *)appBuildString;

// --------------------------------------------------------------------------------
#pragma mark - Conversion Methods
// --------------------------------------------------------------------------------
+ (int)kgToLbs:(float)kilograms;
+ (float)lbsToKg:(NSInteger)lbs;
+ (int)cmToInches:(NSInteger)centimeters;
+ (int)inchesToCm:(NSInteger)inches;

//-------------------------------------------------------
#pragma mark - Time Definitions and Methods
//-------------------------------------------------------
typedef struct  {
    BOOL       negative;
    NSUInteger days;
    NSUInteger hours;
    NSUInteger minutes;
    NSUInteger seconds;
} timeStruct;

+ (NSString *)formatDate:(NSDate *)date withFormatString:(NSString *)formatString;
+ (NSTimeInterval)timeDiff:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (timeStruct)secondsToTimeStructWithUnroundedSeconds:(NSTimeInterval)interval;
+ (NSString *)secondsToHoursMinutesAndSecondsString:(NSTimeInterval)interval;
+ (NSString *)secondsToMinutesAndSecondsString:(NSTimeInterval)interval;

+ (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date;
+ (NSInteger)getYearFromDate:(NSDate *)date;
+ (NSDate *)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

// --------------------------------------------------------------------------------
#pragma mark - String Methods
// --------------------------------------------------------------------------------
+ (NSString *)uuidString;
NSString *APNonNilString(NSString *stringIn);

// --------------------------------------------------------------------------------
#pragma mark - Logging Definitions and Methods
// --------------------------------------------------------------------------------


#if __cplusplus
extern "C" {
#endif

#if __cplusplus
}
#endif

// --------------------------------------------------------------------------------
#pragma mark - Public Instance Methods
// --------------------------------------------------------------------------------
- (void)shutdown;
@end
