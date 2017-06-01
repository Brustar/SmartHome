//
//  ScreenCurtainCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScreenCurtainCellDelegate;

@interface ScreenCurtainCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ScreenCurtainLabel;
@property (weak, nonatomic) IBOutlet UIButton *UPBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *DownBtn;
@property (weak, nonatomic) IBOutlet UISwitch *PowerSwitch;
@property (weak, nonatomic) IBOutlet UIButton *ScreenCurtainBtn;
@property (weak, nonatomic) IBOutlet UIButton *AddScreenCurtainBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ScreenCurtainConstraint;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<ScreenCurtainCellDelegate>delegate;

@end


@protocol ScreenCurtainCellDelegate <NSObject>

@optional
- (void)onUPBtnClicked:(UIButton *)btn;
- (void)onDownBtnClicked:(UIButton *)btn;
- (void)onStopBtnClicked:(UIButton *)btn;

@end
