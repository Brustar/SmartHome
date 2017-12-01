//
//  IpadSceneDetailVC.h
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IpadSceneDetailVC : CustomViewController

@property (nonatomic,strong) NSArray * deviceIdArr;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) int sceneID;
@property (nonatomic, assign) BOOL isGloom;
@property (nonatomic, assign) BOOL isRomantic;
@property (nonatomic, assign) BOOL isSprightly;
@property (nonatomic, assign) NSInteger hostType;//主机类型：0，creston   1, C4
@property (nonatomic, assign) int currentBrightness;//当前亮度

-(void)refreshData:(NSArray *)data;

@end
