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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
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
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    self.cell.colourView.tag = indexPath.row;
    self.cell.colourView.hidden = YES;
    self.cell.colourView.userInteractionEnabled=YES;
    [self.cell.colourView addGestureRecognizer:singleTap];
    self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return self.cell;
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


- (void)changeColor:(id)sender
{
    UIView *colourView = (UIView *)sender;
    
    HRSampleColorPickerViewController *controller= [[HRSampleColorPickerViewController alloc] initWithColor:self.cell.colourView.backgroundColor fullColor:NO indexPathRow:colourView.tag];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)setSelectedColor:(UIColor *)color indexPathRow:(NSInteger)row
{
    //Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[row] intValue]];
    //设置数据库里的色灯的色值
    self.cell.colourView.backgroundColor = color;
    [self save:nil];
}

-(void)save:(id)sender
{
    UIColor *color = self.cell.colourView.backgroundColor;
    NSDictionary *colorDic = [self getRGBDictionaryByColor:color];
    int r = [colorDic[@"R"] floatValue] * 255;
    int g = [colorDic[@"G"] floatValue] * 255;
    int b = [colorDic[@"B"] floatValue] * 255;
    
    NSData *data=[[DeviceInfo defaultManager] changeColor:self.deviceid R:r G:g B:b];
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
