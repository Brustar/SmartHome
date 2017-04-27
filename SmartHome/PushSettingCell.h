//
//  PushSettingCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *SettingNameLabel;//推送名字

@property (weak, nonatomic) IBOutlet UIButton *SeleteTypeBtn;

@property (weak, nonatomic) IBOutlet UILabel *TypeLabel;//通知类型
@property (strong, nonatomic) NSDictionary *valueDict;

-(void)valueAction:(NSDictionary *)valueDict;

-(void)cleanAction;

@end
