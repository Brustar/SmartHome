//
//  ProjectController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ProjectController.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Scene.h"
#import "SceneManager.h"
#import "ORBSwitch.h"
#import "UIViewController+Navigator.h"
#import "UIView+Popup.h"
#import "PackManager.h"
#import "IphoneRoomView.h"

@interface ProjectController ()<ORBSwitchDelegate,IphoneRoomViewDelegate>

@property (nonatomic,strong) NSMutableArray *projectNames;
@property (nonatomic,strong) NSMutableArray *projectIds;
@property (nonatomic,strong) ORBSwitch *switcher;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (nonatomic,strong) NSArray *menus;
@end

@implementation ProjectController

//初始化投影仪数据源
- (void)setupProjectSources {
    _projectSources = [NSMutableArray array];
    _btnArray = [NSMutableArray array];
    NSArray *sources = [SQLManager getSourcesByDeviceID: [self.deviceid integerValue]];
    if (sources.count >0) {
        [_projectSources addObjectsFromArray:sources];
    }
    
    if (_projectSources.count >0) {
        //初始化数据源按钮
        [_projectSources enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            
            DeviceSource *info = (DeviceSource *)obj;
            
            CGFloat btnWidth = 70;
            CGFloat btnHeight = 30;
            UIButton *btn;
            if (Is_iPhoneX) {
            btn = [[UIButton alloc] initWithFrame:CGRectMake(10+(btnWidth+15)*idx, 144, btnWidth, btnHeight)];
            }else{
            btn = [[UIButton alloc] initWithFrame:CGRectMake(10+(btnWidth+15)*idx, 120, btnWidth, btnHeight)];
            }
           
            btn.tag = idx;
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitle:info.sourceName forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            btn.selected = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"control_button"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClickedAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
            [_btnArray addObject:btn];
            
        }];
    }
}

- (void)btnClickedAction:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = !btn.selected;
        
        [_btnArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *button = (UIButton *)obj;
            if (btn.tag != button.tag) {
                button.selected = NO;
            }
        }];
        
        //发切换数据源的指令
        uint8_t channelid = 0x01;
        DeviceSource *info = _projectSources[btn.tag];
        if ([info.channelID isEqualToString:@"01"]) {
            channelid = 0x01;
        }else if ([info.channelID isEqualToString:@"02"]) {
            channelid = 0x02;
        }else if ([info.channelID isEqualToString:@"03"]) {
            channelid = 0x03;
        }else if ([info.channelID isEqualToString:@"04"]) {
            channelid = 0x04;
        }else if ([info.channelID isEqualToString:@"05"]) {
            channelid = 0x05;
        }else if ([info.channelID isEqualToString:@"06"]) {
            channelid = 0x06;
        }else if ([info.channelID isEqualToString:@"07"]) {
            channelid = 0x07;
        }else if ([info.channelID isEqualToString:@"08"]) {
            channelid = 0x08;
        }else if ([info.channelID isEqualToString:@"09"]) {
            channelid = 0x09;
        }
        NSData *data = [[DeviceInfo defaultManager] changeSource:channelid deviceID:self.deviceid];
        SocketManager *sock = [SocketManager defaultManager];
        sock.delegate = self;
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
}

-(NSMutableArray *)projectIds
{
    if(!_projectIds)
    {
        _projectIds = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *projects = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];

            for(int i = 0; i < projects.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[projects[i] intValue]];
                if([typeName isEqualToString:@"投影"])
                {
                    [_projectIds addObject:projects[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_projectIds addObject:[SQLManager singleDeviceWithCatalogID:projector byRoom: self.roomID]];
        }else{
            [_projectIds addObject:self.deviceid];
        }
    }
    return _projectIds;
}
-(NSMutableArray *)projectNames
{
    if(!_projectNames)
    {
        _projectNames = [NSMutableArray array];
        for(int i = 0; i < self.projectIds.count; i++)
        {
            int projectID = [self.projectIds[i] intValue];
            [_projectNames addObject:[SQLManager deviceNameByDeviceID:projectID]];
        }
    }
    return _projectNames;
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    int index = 0,i = 0;
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
        if (device.hTypeId == projector) {
            index = i;
        }
        i++;
    }
    
    IphoneRoomView *menu = [[IphoneRoomView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 40)];
    
    menu.dataArray = deviceNames;
    menu.delegate = self;
    
    [menu setSelectButton:index];
    [self.menuContainer addSubview:menu];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    Device *device = self.menus[index];
    [self.navigationController pushViewController:[DeviceInfo calcController:device.hTypeId] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - 投影机",roomName];
    [self setNaviBarTitle:self.title];
    [self initSwitcher];
    
    self.deviceid = [SQLManager singleDeviceWithCatalogID:projector byRoom: self.roomID];
    [self setupProjectSources];// 初始化投影仪数据源
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Amplifier class]]) {
                self.switcher.isOn=((Amplifier *)[_scene.devices objectAtIndex:i]).waiting;
            }
        }
    }
    
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:nil inactiveBackgroundImage:[UIImage imageNamed:@"plugin_off"] activeBackgroundImage:[UIImage imageNamed:@"plugin_on"] frame:CGRectMake(0, 0, SWITCH_SIZE, SWITCH_SIZE)];
    self.switcher.center = CGPointMake(self.view.bounds.size.width / 2,
                                       self.view.bounds.size.height / 2);
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
    [self.switcher constraintToCenter:SWITCH_SIZE];
}

-(IBAction)save:(id)sender
{
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.switcher.isOn];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            self.switcher.isOn=proto.action.state;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    
}

@end
