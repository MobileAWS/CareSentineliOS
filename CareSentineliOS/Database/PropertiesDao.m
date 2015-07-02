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
#import "DeviceEnabledProperty.h"

@implementation PropertiesDao

+(DeviceProperty *)saveProperty:(NSString *)name forDevice:(Device *)device withValue:(NSString *)value{
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
    return propertyValue;
}

+(NSMutableArray *)listPropertiesForUser:(NSNumber *) userId{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    return [manager listWithModel:[DevicePropertyDescriptor class] forQuery:[NSString stringWithFormat:@"SELECT %@ FROM devices,properties,devices_properties_values WHERE devices.id = device_id AND property_id = properties.id AND devices.user_id = %@ ORDER BY devices.id, devices_properties_values.created_at DESC",[[[DevicePropertyDescriptor getPropertiesMapping] allKeys] componentsJoinedByString:@","],userId]];

}

+(NSMutableArray *)listNotificationsForDevice:(NSNumber *) deviceId{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    return [manager listWithModel:[DevicePropertyDescriptor class] forQuery:[NSString stringWithFormat:@"SELECT %@ FROM devices,properties,devices_properties_values WHERE devices.id = device_id AND property_id = properties.id AND devices.id = %@ ORDER BY devices.id, devices_properties_values.created_at DESC",[[[DevicePropertyDescriptor getPropertiesMapping] allKeys] componentsJoinedByString:@","],deviceId]];
    
}

+(NSMutableArray *)listPropertiesForDevice:(NSNumber *) deviceId{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    return [manager listWithModel:[DeviceEnabledProperty class] forQuery:[NSString stringWithFormat:@"SELECT %@ FROM devices,properties,devices_enabled_properties WHERE devices.id = device_id AND property_id = properties.id AND devices.id = %@ ORDER BY devices.id, devices_enabled_properties.id ",[[[DeviceEnabledProperty getPropertiesMapping] allKeys] componentsJoinedByString:@","],deviceId]];
    
}

+(NSMutableArray *)initPropertiesForDevice:(NSNumber *) deviceId{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    [manager insert:[NSString stringWithFormat:@"INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) SELECT %@,p.id,1,0 FROM properties p",deviceId]];
    return [PropertiesDao listPropertiesForDevice:deviceId];
}


+(void)dismistProperty:(NSNumber *)idValue{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    int targetValue = [[[NSNumber alloc] initWithInt:[[NSDate date] timeIntervalSince1970]] intValue];
    [manager update:[NSString stringWithFormat:@"UPDATE devices_properties_values SET dismissed_at = %d WHERE id = %@",targetValue,idValue]];

}

+(void)saveDeviceEnabledProperty:(DeviceEnabledProperty *)property{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    [manager save:property];
}

+(void)removeValuesForDevices:(NSArray *)devicesId{
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    [manager delete:[NSString stringWithFormat:@"DELETE FROM devices_properties_values where device_id IN (%@)",[devicesId componentsJoinedByString:@","]]];
    
}


@end
