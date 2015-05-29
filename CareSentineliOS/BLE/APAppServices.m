//
//  APAppServices.m
//  AppPotential iOS Core Application Services
//
//  Created by Phill Giancarlo on 10/3/13.
//  Copyright (c) 2013 AppPotential. All rights reserved.
//

#import "APAppServices.h"
#import "Constants.h"
#import <UIKit/UIKit.h>

@interface APAppServices()
@end

@implementation APAppServices

static APAppServices   *s_AppServices      = nil;
static float            s_osVersion        = 0.0f;
static NSString        *s_appVersionString = nil;
static NSString        *s_appBuildString   = nil;
static NSDateFormatter *s_dateFormat       = nil;

//-------------------------------------------------------
#pragma mark - Init and Cleanup
//-------------------------------------------------------
- (id)init {
    if (s_AppServices) {
        return s_AppServices;
    }
    self          = [super init];
    
    if (self) {
        s_AppServices    = self;

        // --- Get the iOS version Number
        s_osVersion      = [[UIDevice currentDevice].systemVersion floatValue];
        
        // -- Enable sound effects
    }
    
    return self;
}

- (void)shutdown {
    s_AppServices      = nil;
    s_appVersionString = nil;
    s_appBuildString   = nil;
    s_dateFormat       = nil;
}

- (void)dealloc {
    [self shutdown];
    APLogDealloc
}

//-------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------
+ (APAppServices *)appServicesObject {
    return s_AppServices;
}

+ (float)osVersion {
    return s_osVersion;
}

+ (NSError *)errorObjectWithCode:(NSInteger)code description:(NSString *)description failureReason:(NSString *)reason {
    if (!(description AND reason)) return nil;
    
    NSError             *error     = nil;
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (errorDict) {
        [errorDict setObject:description forKey:NSLocalizedDescriptionKey];
        if (reason) {
            [errorDict setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
        }
        error = [NSError errorWithDomain:kDomainApp code:code userInfo:errorDict];
    }
    
    return error;
}

+ (NSString *)appVersionString {
    if (!s_appVersionString) {
        s_appVersionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return s_appVersionString;
}

+ (NSString *)appBuildString {
    if (!s_appBuildString) {
////        NSLog(@"------> CLASS: %@", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] class]);
        s_appBuildString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    return s_appBuildString;
}

+ (NSString *)uuidString {
    CFUUIDRef uuidRef = CFUUIDCreate(nil);
	
	NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidRef);
	
	CFREL(uuidRef);
    
	return uuidString;
}

//-------------------------------------------------------
#pragma mark - Time Methods
//-------------------------------------------------------
+ (NSString *)formatDate:(NSDate *)date withFormatString:(NSString *)formatString {
    // -- Don't instantiate a formatter if one already exists.
    if (s_dateFormat == nil)
        s_dateFormat = [[NSDateFormatter alloc] init];
    
    [s_dateFormat setDateFormat:formatString];
    
    NSString *dateString = [s_dateFormat stringFromDate:date];
    
    return dateString;
}

+ (NSTimeInterval)timeDiff:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [endDate timeIntervalSinceDate:startDate];
}

+ (timeStruct)secondsToTimeStructWithUnroundedSeconds:(NSTimeInterval)interval {
    double         dblHours;
    double         dblRemainder;
    timeStruct     newTime;
    
    // -- Convert negative interval to positive.
    if (interval < 0) {
        interval = -interval;
        newTime.negative = YES;
    } else
        newTime.negative = NO;
    
    dblHours        = interval / 3600.0f;                  // -- Convert seconds to hours + some fractional minutes
    newTime.hours   = dblHours;                            // -- Trim off the decimal
    newTime.minutes = (dblHours - newTime.hours) * 60.0f;  // -- Convert remaining fraction to minutes.
    dblRemainder    = interval - (newTime.hours * 3600) - (newTime.minutes * 60); // -- Final remainder is seconds.
    dblRemainder    = dblRemainder + 0.5f;                 // -- Round up.
    newTime.seconds = trunc(dblRemainder);
    
    if (newTime.hours >= 24) {
        newTime.days  = newTime.hours / 24;
        newTime.hours = newTime.hours - (newTime.days * 24);
    } else
        newTime.days = 0;
    
    if (newTime.seconds == 60) {
        newTime.minutes++;
        newTime.seconds = 0;
    }
    
    return newTime;
}

+ (NSString *)secondsToHoursMinutesAndSecondsString:(NSTimeInterval)interval {
    timeStruct time = [self secondsToTimeStructWithUnroundedSeconds:interval];
    
    NSString *hrsString;
    NSString *minString;
    NSString *secString;
    
    if (time.hours < 10)
        hrsString = [NSString stringWithFormat:@"0%lu", (unsigned long)time.hours];
    else
        hrsString = [NSString stringWithFormat:@"%lu", (unsigned long)time.hours];
    
    if (time.minutes < 10)
        minString = [NSString stringWithFormat:@"0%lu", (unsigned long)time.minutes];
    else
        minString = [NSString stringWithFormat:@"%lu", (unsigned long)time.minutes];
    
    if (time.seconds < 10)
        secString = [NSString stringWithFormat:@"0%lu", (unsigned long)time.seconds];
    else
        secString = [NSString stringWithFormat:@"%lu", (unsigned long)time.seconds];
    
    NSString *timeString = [NSString stringWithFormat:@"%@:%@:%@", hrsString, minString, secString];
    
    return timeString;
}

+ (NSString *)secondsToMinutesAndSecondsString:(NSTimeInterval)interval {
    timeStruct time = [self secondsToTimeStructWithUnroundedSeconds:interval];
    
    NSInteger minutes = time.days * 1440 + time.hours * 60 + time.minutes;  // -- 1440 = 60 min * 24 hours
    NSString *minString;
    NSString *secString;
    
    if (minutes < 10)
        minString = [NSString stringWithFormat:@"0%li", (long)minutes];
    else
        minString = [NSString stringWithFormat:@"%li", (long)minutes];
    
    if (time.seconds < 10)
        secString = [NSString stringWithFormat:@"0%lu", (unsigned long)time.seconds];
    else
        secString = [NSString stringWithFormat:@"%lu", (unsigned long)time.seconds];
    
    NSString *timeString = [NSString stringWithFormat:@"%@:%@", minString, secString];
    
    return timeString;
}

+ (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date {
    NSCalendar       *currCal = [NSCalendar currentCalendar];
    NSDateComponents *comps   = [currCal components:NSCalendarUnitYear+NSCalendarUnitMonth+NSCalendarUnitDay+NSCalendarUnitHour+NSCalendarUnitMinute+NSCalendarUnitWeekday+NSCalendarUnitTimeZone fromDate:date];
    
    return comps;
}

+ (NSInteger)getYearFromDate:(NSDate *)date {
    return [self getDateComponentsFromDate:date].year;
}

+ (NSDate *)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    if (!year OR !month OR !day) return nil;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate     *date     = [calendar dateFromComponents:components];
    
    return date;
}

// ------------------------------------------------------------------------------

+ (void)featureNotImplemented:(NSString *)featureName {
    NSString *message = nil;
    
    if (featureName) {
        message = [NSString stringWithFormat:@"The feature %@ is not yet implemented in this version (%@ - build %@) of the software", featureName, [APAppServices appVersionString], [APAppServices appBuildString]];
    } else {
        message = [NSString stringWithFormat:@"This feature is not yet implemented in this version (%@ - build %@) of the software", [APAppServices appVersionString], [APAppServices appBuildString]];
    }
}

// --------------------------------------------------------------------------------
#pragma mark - Conversion Methods
// --------------------------------------------------------------------------------
+ (int)kgToLbs:(float)kilograms {
    float pounds = 2.20462262185 * kilograms;
    
    int lbs = roundf(pounds);

    return lbs;
}

+ (float)lbsToKg:(NSInteger)lbs {
    float kilograms = (float)lbs / 2.20462262185;

    return kilograms;
}

+ (int)cmToInches:(NSInteger)centimeters {
    int inches = roundf((float)centimeters * 0.3937007874);
    
    return inches;
}

+ (int)inchesToCm:(NSInteger)inches {
    int centimeters = roundf((float)inches / 0.3937007874);
    
    return centimeters;
}

// --------------------------------------------------------------------------------
#pragma mark - String Methods
// --------------------------------------------------------------------------------
NSString *APNonNilString(NSString *stringIn) {
    if (!stringIn) return @"";  // -- Return zero length.
    
    return stringIn;
}

// --------------------------------------------------------------------------------
#pragma mark - Logging Methods
// --------------------------------------------------------------------------------

@end
