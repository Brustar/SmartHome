//
//  IphoneDVDController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneDVDController : UIViewController
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;

- (IBAction)popBtnClicked:(id)sender;//开关仓
- (IBAction)homeBtnClicked:(id)sender;//主页
- (IBAction)returnBtnClicked:(id)sender;//返回

@end
