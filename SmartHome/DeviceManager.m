//
//  DeviceManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceManager.h"
#import "Device.h"
@implementation DeviceManager
+(NSArray *)parseDevicesResult:(id)result
{
    NSArray *deviceArray = result[@"messageInfo"];
    NSMutableArray *mutabArr = [NSMutableArray array];
    for(NSDictionary *deviceDic in deviceArray)
    {
        Device *device = [Device new];
        [device setValuesForKeysWithDictionary:deviceDic];
        [mutabArr addObject:device];
    }
    return [mutabArr copy];
}
//从缓存中获取所有设备信息
+(NSArray *)getAllDevicesInfo{
    NSString *devicePath = [[IOManager configPath:@"devices"] stringByAppendingPathComponent:@"deviceConfig.plist"];
    return [NSArray arrayWithContentsOfFile:devicePath];
}


+ (NSArray *)getDeviceModel
{
    NSMutableArray *arrayReturn = [NSMutableArray array];
    
    NSArray *deviceInfos = [self getAllDevicesInfo];
    
    for (NSDictionary *dict in deviceInfos) {
        NSArray *deviceModels = dict[@"equipmentList"];
        for (NSDictionary *deviceModel in deviceModels) {
            Device *device = [Device deviceWithDict:deviceModel];
            [arrayReturn addObject:device];
        }
    }
    
    if (arrayReturn.count == 0 ) {
        return nil;
    }
    
    return [arrayReturn copy];
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
