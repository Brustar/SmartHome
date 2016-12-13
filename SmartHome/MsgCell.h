//
//  MsgCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *unreadcountImage;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;//显示未读消息

@end
