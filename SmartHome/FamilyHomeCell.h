//
//  FamilyHomeCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomStatus.h"
#import "LayerUtil.h"

#define Light_ON_COLOR  RGB(243, 152, 0, 1)
#define Air_ON_COLOR    RGB(0, 172, 151, 1)
#define AV_ON_COLOR     RGB(217, 55, 75, 1)
#define Dev_OFF_COLOR   RGB(0, 0, 0, 1)
#define PM25_COLOR      RGB(159, 160, 160, 0.3)

@interface FamilyHomeCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *pm25Label;

- (void)setRoomAndDeviceStatus:(RoomStatus *)info;//设置房间名字，温／湿度/PM2.5，设备开关状态

- (void)addRingForDevice:(RoomStatus *)info;
- (void)addRingForPM25:(RoomStatus *)info;

@end
