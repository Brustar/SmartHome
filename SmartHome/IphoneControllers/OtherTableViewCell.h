//
//  OtherTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OtherTableViewCellDelegate;

@interface OtherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UIButton *OtherSwitchBtn;
@property (weak, nonatomic) IBOutlet UIButton *AddOtherBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *OtherConstraint;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<OtherTableViewCellDelegate>delegate;

@end


@protocol OtherTableViewCellDelegate <NSObject>

@optional
- (void)onOtherSwitchBtnClicked:(UIButton *)btn;

@end
