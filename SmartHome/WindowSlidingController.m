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
    self.title = [NSString stringWithFormat:@"%@ - %@",roomName,windowType];
    [self setNaviBarTitle:self.title];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:windowOpener byRoom:self.roomID];
    [self initSwitcher];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:nil inactiveBackgroundImage:[UIImage imageNamed:@"plugin_off"] activeBackgroundImage:[UIImage imageNamed:@"plugin_on"] frame:CGRectMake(0, 0, SWITCH_SIZE, SWITCH_SIZE)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
    [self.switcher constraintToCenter:SWITCH_SIZE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    
}

@end
