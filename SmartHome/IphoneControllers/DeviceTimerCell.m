//
//  DeviceTimerCell.m
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceTimerCell.h"

@implementation DeviceTimerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)deviceTimerBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.deviceTimeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
    }else {
        [self.deviceTimeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onDeviceTimerBtnClicked:)]) {
        [_delegate onDeviceTimerBtnClicked:btn];
    }
}

- (void)setInfo:(DeviceTimerInfo *)info {
    if (info) {
        self.deviceName.text = info.deviceName;
        self.timeLabel.text = [NSString stringWithFormat:@"%@-%@, %@", info.startTime, info.endTime, [self repeatString:info.repetition]];
        self.deviceTimeBtn.tag = info.timerID;
        self.deviceTimeBtn.selected = info.isActive;//标识是否开启定时器
        
        //启动定时开关按钮
        if (info.isActive == 1) { //启用
            [self.deviceTimeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
        }else { //停用
            [self.deviceTimeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }
        
    }
}

- (NSString *)repeatString:(NSString *)weekString {
    if (weekString.length <= 0) {
        return @"永不";
    }else {
        NSMutableArray *weekArray = [NSMutableArray array];
        NSArray *arr = [weekString componentsSeparatedByString:@","];
        if (arr.count >0) {
            [weekArray addObjectsFromArray:arr];
        }
        
        //weekArray 删除最后一个元素, 最后一个元素是空白字符
        [weekArray removeObjectAtIndex:weekArray.count-1];
        
        if (weekArray.count >0) {
            NSMutableDictionary *weeksDict = [NSMutableDictionary dictionary];
            for(NSString *weekStr in weekArray) {
                weeksDict[weekStr] = @"1";
            }
            
            int week[7] = {0}; //初始化 7天全为0
            
            for (NSString *key in [weeksDict allKeys]) {
                int index = [key intValue];
                int select = [weeksDict[key] intValue];
                
                week[index] = select;
            }
            
            NSMutableString *display = [NSMutableString string];
            
            if (week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 0 && week[6] == 0) {
                [display appendString:@"永不"];
            }
            else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 1 && week[6] == 1) {
                [display appendString:@"每天"];
            }
            else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 0 && week[6] == 0) {
                [display appendString:@"工作日"];
            }
            else if ( week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 1 && week[6] == 1 ) {
                [display appendString:@"周末"];
            }
            else {
                for (int i = 1; i < 7; i++) {
                    if (week[i] == 1) {
                        switch (i) {
                            case 1:
                                [display appendString:@"周一、"];
                                break;
                                
                            case 2:
                                [display appendString:@"周二、"];
                                break;
                                
                            case 3:
                                [display appendString:@"周三、"];
                                break;
                                
                            case 4:
                                [display appendString:@"周四、"];
                                break;
                                
                            case 5:
                                [display appendString:@"周五、"];
                                break;
                                
                            case 6:
                                [display appendString:@"周六、"];
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
                if (week[0] == 1) {
                    [display appendString:@"周日、"];
                }
            }
           
            return display;
            
        }else {
            return @"永不";
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
