//
//  WindowSlidingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define windowType @"智能推窗器"

#import "WindowSlidingController.h"

#import "SQLManager.h"
#import "SocketManager.h"
#import "WinOpener.h"
#import "SceneManager.h"
#import "UIViewController+Navigator.h"
#import "ORBSwitch.h"
#import "UIView+Popup.h"

@interface WindowSlidingController ()<ORBSwitchDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (nonatomic,strong) NSMutableArray *windowSlidNames;
@property (nonatomic,strong) NSMutableArray *windowSlidIds;

@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (nonatomic,strong) ORBSwitch *switcher;
@end

@implementation WindowSlidingController

-(NSMutableArray *)windowSlidIds
{
    if(!_windowSlidIds)
    {
        _windowSlidIds = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *windowSlid = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < windowSlid.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[windowSlid[i] intValue]];
                if([typeName isEqualToString:windowType])
                {
                    [_windowSlidIds addObject:windowSlid[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_windowSlidIds addObject:[SQLManager singleDeviceWithCatalogID:windowOpener byRoom:self.roomID]];
        }else{
            if (self.deviceid) {
            [_windowSlidIds addObject:self.deviceid];
            }
        }

    }
    return _windowSlidIds;
}
-(NSMutableArray *)windowSlidNames
{
    if(!_windowSlidNames)
    {
        _windowSlidNames = [NSMutableArray array];
        
        for(int i = 0; i < self.windowSlidIds.count; i++)
        {
            int windSlidID = [self.windowSlidIds[i] intValue];
            [_windowSlidNames addObject:[SQLManager deviceNameByDeviceID:windSlidID]];
        }
    }
    return _windowSlidNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSArray *menus = [SQLManager singleProductByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - %@",roomName,windowType]];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:windowOpener byRoom:self.roomID];
    [self initSwitcher];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
    }
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"plugin_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 750/2, 750/2)];
    self.switcher.center = CGPointMake(self.view.bounds.size.width / 2,
                                       self.view.bounds.size.height / 2);
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
    [self.switcher constraintToCenter:375];
}

-(IBAction)save:(id)sender
{

    WinOpener *device=[[WinOpener alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
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

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"plugin_on" : @"plugin_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];
    
}

@end
