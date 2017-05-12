//
//  ScreenCurtainController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScreenCurtainController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Amplifier.h"
#import "Scene.h"
#import "SceneManager.h"
#import "UIViewController+Navigator.h"

@interface ScreenCurtainController ()

@property (nonatomic,strong) NSMutableArray *screenCurtainNames;
@property (nonatomic,strong) NSMutableArray *screenCurtainIds;
@property (nonatomic,strong) DetailTableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;

@end

@implementation ScreenCurtainController

-(NSMutableArray *)screenCurtainIds
{
    if(!_screenCurtainIds)
    {
        _screenCurtainIds = [NSMutableArray array];
        if(self.sceneid > 0 && !_isAddDevice )
        {
            NSArray *screenCurtain = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < screenCurtain.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[screenCurtain[i] intValue]];
                if([typeName isEqualToString:@"幕布"])
                {
                    [_screenCurtainIds addObject:screenCurtain[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_screenCurtainIds addObject:[SQLManager singleDeviceWithCatalogID:amplifier byRoom:self.roomID]];
        }else{
            [_screenCurtainIds addObject:self.deviceid];
        }
    }
    return _screenCurtainIds;
}
-(NSMutableArray *)screenCurtainNames
{
    if(!_screenCurtainNames)
    {
        _screenCurtainNames = [NSMutableArray array];
        for(int i = 0; i < self.screenCurtainIds.count; i++)
        {
            int screenCurtainID = [self.screenCurtainIds[i] intValue];
            [_screenCurtainNames addObject:[SQLManager deviceNameByDeviceID:screenCurtainID]];
        }
 
    }
    return _screenCurtainNames;
}

- (IBAction)upBtnAction:(UIButton *)sender {
    NSData *data = [[DeviceInfo defaultManager] upScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)stopBtnAction:(UIButton *)sender {
    NSData *data = [[DeviceInfo defaultManager] stopScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)downBtnAction:(UIButton *)sender {
    NSData *data = [[DeviceInfo defaultManager] downScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 幕布",roomName]];
    self.deviceid =[SQLManager singleDeviceWithCatalogID:screen byRoom:self.roomID];
    NSArray *menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.cell.power]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.cell.power.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.cell.power.isOn];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
