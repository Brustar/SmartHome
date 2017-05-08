//
//  ProjectController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ProjectController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Scene.h"
#import "SceneManager.h"
#import "ORBSwitch.h"
#import "UIViewController+Navigator.h"

@interface ProjectController ()<ORBSwitchDelegate>

@property (nonatomic,strong) NSMutableArray *projectNames;
@property (nonatomic,strong) NSMutableArray *projectIds;
@property (nonatomic,strong) ORBSwitch *switcher;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;

@end

@implementation ProjectController


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

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 投影机",roomName]];
    [self initSwitcher];
    
    NSArray *menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
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
}

-(void) initSwitcher
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"lighting_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 194, 194)];
    self.switcher.center = CGPointMake(self.view.bounds.size.width / 2,
                                       self.view.bounds.size.height / 2);
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    
    [self.view addSubview:self.switcher];
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.switcher]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.switcher.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.switcher.isOn];
    NSArray *menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    
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

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    [self save:self.switcher];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"plugin_on" : @"plugin_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];
    
}

@end
