//
//  KeyChainManager.m
//  CareSentineliOS
//
//  Created by Mike on 6/22/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "KeyChainManager.h"

@implementation KeyChainManager

+(void)savePassword:(NSString *)value forAccount:(NSString *)account{
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id)(kSecClass)];
    [query setObject:account forKey:(__bridge id)(kSecAttrAccount)];
    [query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id) kSecAttrAccessible];
    
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)(query), nil);
    if (result == errSecSuccess){
        NSDictionary *values = @{(__bridge id)kSecValueData:[value dataUsingEncoding:NSUTF8StringEncoding]};
        result = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)values);
        if (result != errSecSuccess){
            NSLog(@"Cannot update password value");
        }
    }
    else{
        [query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        result = SecItemAdd((__bridge CFDictionaryRef)query, nil);
        if (result != errSecSuccess){
            NSLog(@"Cannot save password value");
        }
    }
}

+(NSString *)getPasswordForAccount:(NSString *)account{
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id)(kSecClass)];
    [query setObject:account forKey:(__bridge id)(kSecAttrAccount)];
    [query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id) kSecAttrAccessible];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFDataRef password = nil;
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)(query), (CFTypeRef *)&password);
    
    if (result == errSecSuccess){
        return [[NSString alloc] initWithData:(__bridge NSData*)password encoding:NSUTF8StringEncoding];
    }
    else{
        return nil;
    }

}

@end

