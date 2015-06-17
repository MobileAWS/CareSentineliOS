//
//  PropertiesDao.m
//  CareSentineliOS
//
//  Created by Mike on 6/11/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "PropertiesDao.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "Property.h"
#import "DeviceProperty.h"
#import "DevicePropertyDescriptor.h"

@implementation PropertiesDao

+(void)saveProperty:(NSString *)name forDevice:(Device *)device withValue:(NSString *)value{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    Property *prop = (Property *)[manager findWithCondition:[NSString stringWithFormat:@"name = '%@'",name] forModel:[Property class]];
    
    if(prop == nil){
        prop = [[Property alloc]init];
        prop.name = name;
        prop = (Property *)[manager save:prop];
    }
    
    DeviceProperty *propertyValue = [[DeviceProperty alloc] init];
    propertyValue.deviceId = device.id;
    propertyValue.value = value;
    propertyValue.propertyId = prop.id;
    propertyValue.createdAt = [[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]];
    [manager save:propertyValue];    
}

+(NSMutableArray *)listPropertiesForUser:(NSNumber *) userId{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    return [manager listWithModel:[DevicePropertyDescriptor class] forQuery:[NSString stringWithFormat:@"SELECT %@ FROM devices,properties,devices_properties_values WHERE devices.id = device_id AND property_id = properties.id AND devices.user_id = %@ ORDER BY devices_properties_values.created_at DESC,devices.id DESC",[[[DevicePropertyDescriptor getPropertiesMapping] allKeys] componentsJoinedByString:@","],userId]];

}


@end
