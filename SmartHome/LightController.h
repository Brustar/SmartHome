//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "public.h"
#import "SceneManager.h"
#import "Light.h"
#import "ColourTableViewCell.h"

#import "SocketManager.h"
#import "CustomNaviBarView.h"
#import "CustomViewController.h"

#define MAX_ROTATE_DEGREE 135

@interface LightController : CustomViewController<TcpRecvDelegate>

@property (nonatomic, readonly) CustomNaviBarView *viewNaviBar;

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (strong, nonatomic) IBOutlet UIButton *favorite;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;

@property (strong, nonatomic) Scene *scene;

@end
