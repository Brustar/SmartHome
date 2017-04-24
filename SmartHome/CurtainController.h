//
//  CurtainController.h
//  SmartHome
//
//  Created by Brustar on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "SceneManager.h"
#import "Curtain.h"
#import "CurtainTableViewCell.h"
#import "CustomNaviBarView.h"
#import "CustomViewController.h"

@interface CurtainController : CustomViewController

@property (strong, nonatomic) IBOutlet CurtainTableViewCell *cell;
@property (nonatomic, readonly) CustomNaviBarView *viewNaviBar;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;

@end
