//
//  IphoneAddTVChannelController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IphoneAddTVChannelController : CustomViewController
@property (nonatomic,assign) NSString *deviceid;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UITextField *channelNumber;
@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (nonatomic,strong) UIImage *chooseImage;
@property (nonatomic,strong) NSString *chooseImgeName;
@property (nonatomic,strong) NSString *eNumber;

@end
