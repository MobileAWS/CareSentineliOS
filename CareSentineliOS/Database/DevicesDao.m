//
//  DevicesDao.m
//  CareSentineliOS
//
//  Created by Mike on 7/12/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DevicesDao.h"
#import "DatabaseManager.h"

@implementation DevicesDao
+(void)deleteDeviceData:(Device *)device{
    
    DatabaseManager *manager = [DatabaseManager getSharedIntance];
    
    /** Delete notifications data */
    [manager delete:[NSString stringWithFormat:@"DELETE FROM devices_properties_values where device_id = %@",device.id]];
    /** Delete enabled properties for device **/
    [manager delete:[NSString stringWithFormat:@"DELETE FROM devices_enabled_properties where device_id = %@",device.id]];
    /** Delete device itself */
    [manager delete:[NSString stringWithFormat:@"DELETE FROM devices where id = %@",device.id]];
    
}
@end
