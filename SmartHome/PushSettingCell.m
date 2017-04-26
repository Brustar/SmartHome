//
//  PushSettingCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "PushSettingCell.h"

@implementation PushSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)valueAction:(NSDictionary *)valueDict{
    _valueDict = valueDict;
    [_SettingNameLabel setText:[valueDict objectForKey:@"name"]];
    [_TypeLabel setText:[valueDict objectForKey:@"notifyway"]];
    
    CGRect groupRect = self.frame;
    groupRect.origin.x = 0;
    if([[valueDict objectForKey:@"group"] count] > 0){
    }else{
        groupRect.origin.x = 32;
    }
    [self setFrame:groupRect];
}

-(void)cleanAction{
    [_SettingNameLabel setText:nil];
    [_TypeLabel setText:@""];
    
}

@end
