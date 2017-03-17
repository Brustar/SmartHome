//
//  IphoneLightController.m
//  SmartHome
//
//  Created by zhaona on 2016/11/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneLightController.h"
#import "Scene.h"
#import "SQLManager.h"
#import "Room.h"
#import "LightCell.h"
#import "Device.h"
#import "SceneManager.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "CurtainTableViewCell.h"
#import "IphoneAirCell.h"
#import "ColourTableViewCell.h"
#import "HRSampleColorPickerViewController.h"

@interface IphoneLightController ()<UITableViewDelegate,UITableViewDataSource,HRColorPickerViewControllerDelegate, ColourTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet ColourTableViewCell *cell;
@property (nonatomic,strong) NSArray * roomArrs;
@property (nonatomic,strong) NSArray * lightArrs;
@property (nonatomic,strong) NSString * deviceid;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,strong) NSArray * ColourLightArr;
@property (nonatomic,strong) NSArray * SwitchLightArr;

@end

@implementation IphoneLightController
-(NSArray *)SwitchLightArr
{
    if (_SwitchLightArr == nil) {
        _SwitchLightArr = [NSArray array];
    }

    return _SwitchLightArr;
}
-(NSArray *)ColourLightArr
{
    if (_ColourLightArr == nil) {
        _ColourLightArr = [NSArray array];
    }
    
    return _ColourLightArr;

}
-(NSArray *)lightArrs
{
    if (!_lightArrs) {
        _lightArrs = [NSArray array];
    }

    return _lightArrs;
}

#pragma mark - 明快,幽静,浪漫

//明快
- (void)SprightlierBtn:(id)sender {
    
    [[SceneManager defaultManager] sprightly:[self.sceneid intValue]];
}
//幽静
- (void)PeacefulBtn:(id)sender {
    
    [[SceneManager defaultManager] gloom:[self.sceneid intValue]];
}
//浪漫
- (void)RomanceBtn:(id)sender {
    
    [[SceneManager defaultManager] romantic:[self.sceneid intValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.isEditScene) {
        self.tableView.tableFooterView = [UIView new];
    }else {
        self.tableView.tableFooterView = [self createTableFooterView];
    }
    
    _lightArrs   = [SQLManager getDeviceByRoom:self.roomID];
//    _curtainArrs = [SQLManager getCurtainByRoom:self.roomID];
//    _airArrs     = [SQLManager getAirDeviceByRoom:self.roomID];
    _ColourLightArr = [SQLManager getColourLightByRoom:self.roomID];
    _SwitchLightArr = [SQLManager getSwitchLightByRoom:self.roomID];
    [self.tableView registerNib:[UINib nibWithNibName:@"ColourTableViewCell" bundle:nil] forCellReuseIdentifier:@"ColourTableViewCell"];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    self.scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    self.title = [SQLManager getRoomNameByRoomID:self.roomID];
}

- (UIView *)createTableFooterView {
    
    CGFloat btnWidth = 40.0f;
    CGFloat btnHeight = 40.0f;
    CGFloat gap = (UI_SCREEN_WIDTH-btnWidth*3)/4;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, btnHeight*2)];
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((i+1)*gap + i*btnWidth, btnHeight/2, btnWidth, btnHeight)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((i+1)*gap + i*btnWidth, btnHeight/2+btnHeight, btnWidth, btnHeight/2)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        btn.layer.cornerRadius = 4.0;
        btn.layer.masksToBounds = YES;
        if (i == 0) {
            [btn setImage:[UIImage imageNamed:@"u83"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(SprightlierBtn:) forControlEvents:UIControlEventTouchUpInside];
            label.text = @"明快";
        }else if (i == 1) {
            [btn setImage:[UIImage imageNamed:@"u85"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(PeacefulBtn:) forControlEvents:UIControlEventTouchUpInside];
            label.text = @"幽静";
        }else if (i == 2) {
            [btn setImage:[UIImage imageNamed:@"u87"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(RomanceBtn:) forControlEvents:UIControlEventTouchUpInside];
            label.text = @"浪漫";
        }
        [view addSubview:btn];
        [view addSubview:label];
    }
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return _lightArrs.count;
    }if (section == 1) {
     return _ColourLightArr.count;
    }
    return _SwitchLightArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.roomID = self.roomID;
        cell.sceneID = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArrs[indexPath.row] intValue]];
        cell.LightNameLabel.text = device.name;
        cell.slider.continuous = NO;
        cell.deviceid = self.lightArrs[indexPath.row];
    
        return cell;

    }


    if (indexPath.section == 1) {
        //调色灯
        self.cell = [tableView dequeueReusableCellWithIdentifier:@"ColourTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[indexPath.row] intValue]];
        self.cell.lable.text = device.name;
        self.cell.deviceID = device.eID;
        self.cell.delegate = self;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
        self.cell.colourView.tag = indexPath.row;
        self.cell.colourView.userInteractionEnabled=YES;
        [self.cell.colourView addGestureRecognizer:singleTap];
        self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.cell;
    }
    self.cell = [tableView dequeueReusableCellWithIdentifier:@"ColourTableViewCell" forIndexPath:indexPath];
    Device *device = [SQLManager getDeviceWithDeviceID:[_SwitchLightArr[indexPath.row] intValue]];
    self.cell.lable.text = device.name;
    self.cell.deviceID = device.eID;
    self.cell.delegate = self;
    self.cell.colourView.tag = indexPath.row;
    self.cell.colourView.hidden = YES;
    self.cell.colourView.userInteractionEnabled=YES;
    self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return self.cell;

}
-(IBAction)changeColor:(id)sender
{
    HRSampleColorPickerViewController *controller= [[HRSampleColorPickerViewController alloc] initWithColor:self.cell.backgroundColor fullColor:NO indexPathRow:0];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[indexPath.row] intValue]];
        NSString *deviceID = [NSString stringWithFormat:@"%d", device.eID];
        
        ColourTableViewCell *colorCell = [tableView cellForRowAtIndexPath:indexPath];
        
        [self changeColor:colorCell.colourView.backgroundColor deviceID:deviceID  indexPathRow:indexPath.row];
        
        
    }
}

#pragma mark - ColourTableViewCellDelegate
- (void)lightSwitchValueChanged:(UISwitch *)lightSwitch deviceID:(int)deviceID {
    NSString *devID = [NSString stringWithFormat:@"%d", deviceID];
   
        //发指令
        NSData *data = [[DeviceInfo defaultManager] toogleLight:lightSwitch.on deviceID:devID];
        NSLog(@"color light switch data:%@", data);
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    
}


- (void)changeColor:(UIColor *)color deviceID:(NSString *)deviceID indexPathRow:(NSInteger )index
{
    HRSampleColorPickerViewController *controller= [[HRSampleColorPickerViewController alloc] initWithColor:color fullColor:NO indexPathRow:index];
    controller.deviceID = deviceID;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setSelectedColor:(UIColor *)color deviceID:(NSString *)deviceID indexPathRow:(NSInteger)row
{

    ColourTableViewCell *colorCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
    colorCell.colourView.backgroundColor = color;
    [self save:color deviceID:deviceID];

}

-(void)save:(UIColor *)color deviceID:(NSString *)deviceID
{
    NSDictionary *colorDic = [self getRGBDictionaryByColor:color];
    int r = [colorDic[@"R"] floatValue] * 255;
    int g = [colorDic[@"G"] floatValue] * 255;
    int b = [colorDic[@"B"] floatValue] * 255;
    
    NSData *data=[[DeviceInfo defaultManager] changeColor:deviceID R:r G:g B:b];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:3];

}
- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([originColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @{@"R":@(r),
             @"G":@(g),
             @"B":@(b),
             @"A":@(a)};
}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag == 0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON || proto.action.state == 0x0b || proto.action.state == 0x0a)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            //创建一个消息对象
            NSNotification * notice = [NSNotification notificationWithName:@"light" object:nil userInfo:@{@"state":@(proto.action.state),@"r":@(proto.action.RValue),@"g":@(proto.action.G),@"b":@(proto.action.B)}];
            //发送消息
            [[NSNotificationCenter defaultCenter] postNotification:notice];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 43;
    }
    if (indexPath.section == 2) {
        return 43;
    }

    return 76;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
