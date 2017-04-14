//
//  IphoneNetTvController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IphoneNetTvController : CustomViewController
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) int roomID;

- (IBAction)homeBtnClicked:(id)sender;//主页

- (IBAction)returnBtnClicked:(id)sender;//返回
@end
