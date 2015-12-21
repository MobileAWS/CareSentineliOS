//
//  ConctactDao.h
//  CareSentineliOS
//
//  Created by Andres Prada on 12/18/15.
//  Copyright © 2015 MobileAWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface ContactDao : NSObject
+(void)deleteContactData:(Contact *)contact;
+(void)addContactData:(Contact *)contact;
+(NSArray *)getAllContactData;
@end
