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

//+(NSArray *)getTypeNameForDevice{
//    
//    NSArray *deviceInfos = [self getAllDevicesInfo];
//    NSMutableArray *subTypeNameArrs = [NSMutableArray array];
//    //NSString *lastSubType;
//    for(NSDictionary *dic in deviceInfos)
//    {
//        NSArray *equipmentList = dic[@"equipmentList"];
//        for(NSDictionary *equipmentDic in equipmentList)
//        {
//            NSString *subTypeName = equipmentDic[@"subTypeName"];
//            //lastSubType = subTypeName;
//            if(subTypeNameArrs.count == 0)
//            {
//                [subTypeNameArrs addObject:subTypeName];
//            }else {
//                for(int i = 0; i < subTypeNameArrs.count; i++)
//                {
//                    if(subTypeName != subTypeNameArrs[i])
//                    {
//                        [subTypeNameArrs addObject:subTypeName];
//                        break;
//                    }
//                }
//
//            }
//        }
//    }
//    return [subTypeNameArrs copy];
//}
+ (NSArray *)getDeviceType
{
    NSArray *info =[self getAllDevicesInfo];
    NSMutableArray *deviceTypeArray = [NSMutableArray array];
    
    for (NSDictionary *room in info )
    {
        NSArray *roomDevices = room[@"equipmentList"];
        
        for (NSDictionary *device in roomDevices)
        {
            NSString *hTypeId = device[@"hTypeId"];
            
            int i = 0;
            NSMutableArray *devices = nil;
            for ( i = 0; i < deviceTypeArray.count; i++)
            {
                NSDictionary *deviceType = deviceTypeArray[i];
                devices = deviceType[@"device"];
                
                if (hTypeId == deviceType[@"hTypeId"])
                {
                    continue;
                }
            }
            
            if ( i < deviceTypeArray.count)
                // 好像代码里面有一个设备的模型  这里可以直接把模型增加到数组里面
            {
                [devices addObject:device];
            }
            else
            {
                NSMutableDictionary *newDeviceType = [NSMutableDictionary dictionary];
                newDeviceType[@"hTypeId"] = hTypeId;
                newDeviceType[@"typeName"] = device[@"typeName"];
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:device];
                newDeviceType[@"device"] = array;
                [deviceTypeArray addObject:newDeviceType];
            }
        }
    }
    return deviceTypeArray;
}

@end
