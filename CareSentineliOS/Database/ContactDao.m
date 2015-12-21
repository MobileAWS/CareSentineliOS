//
//  ConctactDao.m
//  CareSentineliOS
//
//  Created by Andres Prada on 12/18/15.
//  Copyright © 2015 MobileAWS. All rights reserved.
//

#import "ContactDao.h"
#import "DatabaseManager.h"
#import "Contact.h"

@implementation ContactDao



+(void)deleteContactData:(Contact *)contact{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    
    /** Delete notifications data */
    [manager delete:[NSString stringWithFormat:@"DELETE FROM contacts where id = %@",contact.id]];
    

}
+(void)addContactData:(Contact *)contact{
    

}
+(NSArray *)getAllContactData{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    NSMutableArray *listContact= [manager listWithModel:[Contact class] forQuery:[NSString stringWithFormat:@"SELECT * FROM contacts  ORDER BY id DESC",nil]];
    NSArray *array = [listContact copy];
    return array;
}
@end
