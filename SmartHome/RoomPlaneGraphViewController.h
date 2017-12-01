//
//  RoomPlaneGraphViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/10/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "SQLManager.h"
#import "HttpManager.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "UIButton+WebCache.h"
#import "NewLightCell.h"
#import "NewColourCell.h"
#import "PowerLightCell.h"
#import "FMTableViewCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "BjMusicTableViewCell.h"
#import "IpadDVDTableViewCell.h"
#import "IpadTVCell.h"
#import "UIImageView+WebCache.h"
#import "UIView_extra.h"
#import "LightController.h"
#import "AirController.h"
#import "NewWindController.h"
#import "CurtainController.h"
#import "CustomSliderViewController.h"



@interface RoomPlaneGraphViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource, TcpRecvDelegate, NewLightCellDelegate, PowerLightCellDelegate, NewColourCellDelegate, CurtainTableViewCellDelegate, BjMusicTableViewCellDelegate, OtherTableViewCellDelegate, HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (weak, nonatomic) IBOutlet UIImageView *planeGraph;
@property (nonatomic, strong) NSMutableArray *deviceIDArray;//该房间的所有设备ID
@property (nonatomic,strong) NSMutableArray * lightArray;//灯光(存储的是设备id)
@property (nonatomic,strong) NSMutableArray * curtainArray;//窗帘
@property (nonatomic,strong) NSMutableArray * environmentArray;//环境
@property (nonatomic,strong) NSMutableArray * multiMediaArray;//影音
@property (nonatomic,strong) NSMutableArray * intelligentArray;//智能单品
@property (nonatomic,strong) NSMutableArray * securityArray;//安防
@property (nonatomic,strong) NSMutableArray * sensorArray;//感应器
@property (nonatomic,strong) NSMutableArray * otherTypeArray;//其他
@property (nonatomic,strong) NSMutableArray * colourLightArr;//调色
@property (nonatomic,strong) NSMutableArray * switchLightArr;//开关
@property (nonatomic,strong) NSMutableArray * lightArr;//调光
@property (nonatomic, assign) NSInteger hostType;//主机类型：0，creston   1, C4
@property (nonatomic,assign)  NSInteger deviceType_count;//设备种类数量
@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, assign) CGFloat photoWidth;
@property (nonatomic, assign) CGFloat photoHeight;

@end
