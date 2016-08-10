//
//  DeviceManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceManager.h"
#import "Device.h"
#import "FMDatabase.h"
@implementation DeviceManager

//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo{
   
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
     NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Devices"];
       
        while ([resultSet next]){
            Device *device = [Device new];
            device.eID = [resultSet intForColumn:@"ID"];
            device.name = [resultSet stringForColumn:@"NAME"];
            device.sn = [resultSet stringForColumn:@"sn"];
            device.birth = [resultSet stringForColumn:@"birth"];
            device.guarantee = [resultSet stringForColumn:@"guarantee"];
            device.model = [resultSet stringForColumn:@""];
            device.price = [resultSet doubleForColumn:@"price"];
            device.purchase = [resultSet stringForColumn:@"purchase"];
            device.producer = [resultSet stringForColumn:@"producer"];
            device.gua_tel = [resultSet stringForColumn:@"gua_tel"];
            device.power = [resultSet intForColumn:@"power"];
            device.current = [resultSet doubleForColumn:@"current"];
            device.voltagge = [resultSet intForColumn:@"voltagge"];
            device.protocol = [resultSet stringForColumn:@"protocol"];
            device.rID = [resultSet intForColumn:@"rID"];
            device.eNumber = [resultSet intForColumn:@"eNumber"];
            device.hTypeId = [resultSet intForColumn:@"hTypeId"];
            device.subTypeId = [resultSet intForColumn:@"subTypeId"];
            device.typeName = [resultSet stringForColumn:@""];
            device.subTypeName = [resultSet stringForColumn:@"subTypeName"];
            
            [deviceModels addObject:device];
            
        }
    
        
    }
    [db close];
    return [deviceModels copy];
    
    
}




+(NSArray *)devicesByRoomId:(NSInteger)roomId
{
    NSMutableArray *devices = [NSMutableArray array];
   NSArray *messageInfo = [self getAllDevicesInfo];
    for(NSDictionary *deviceDic in messageInfo)
    {
        NSInteger rID = [deviceDic[@"rId"] integerValue];
        if(rID == roomId)
        {
            NSArray *equipmentList = deviceDic[@"equipmentList"];
            for(NSDictionary *equipmentDic in equipmentList)
            {
                Device *device = [Device deviceWithDict:equipmentDic];
                [devices addObject:device];
            }
        }
    }
    return [devices copy];
}

@end
