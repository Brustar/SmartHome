//
//  CurtainC4TableViewCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/9/29.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"
#import "SceneManager.h"

@protocol CurtainC4TableViewCellDelegate;

@interface CurtainC4TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak,nonatomic) NSString *deviceid;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchBtnTrailingConstraint;
@property (nonatomic, assign) id<CurtainC4TableViewCellDelegate>delegate;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,assign) int roomID;

- (IBAction)closeBtnClicked:(id)sender;
- (IBAction)stopBtnClicked:(id)sender;
- (IBAction)openBtnClicked:(id)sender;

- (void)query:(NSString *)deviceid delegate:(id)delegate;

@end


@protocol CurtainC4TableViewCellDelegate <NSObject>

@optional
- (void)onCurtainSwitchBtnClicked:(UIButton *)btn deviceID:(int)deviceID;

@end
