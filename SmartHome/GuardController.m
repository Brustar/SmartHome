 //
//  GuardController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "GuardController.h"
#import "EntranceGuard.h"
#import "Scene.h"
#import "SceneManager.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SQLManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define guardType @"智能门锁"

@interface GuardController ()

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSMutableArray *guardNames;
@property (nonatomic,strong) NSMutableArray *guardIDs;
@property (weak, nonatomic) IBOutlet UIButton *switcher;

@end

@implementation GuardController

-(NSMutableArray *)guardIDs
{
    if(!_guardIDs)
    {
        _guardIDs = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *guard = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < guard.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[guard[i] intValue]];
                if([typeName isEqualToString:guardType])
                {
                    [_guardIDs addObject:guard[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_guardIDs addObject:[SQLManager singleDeviceWithCatalogID:doorclock byRoom:self.roomID]];
        }else{
            [_guardIDs addObject:self.deviceid];
        }
    }
    return _guardIDs;
    
    
}
-(NSMutableArray *)guardNames
{
    if(!_guardNames)
    {
        
        _guardNames = [NSMutableArray array];
        
        for(int i = 0; i < self.guardIDs.count; i++)
        {
            int guardId = [self.guardIDs[i] intValue];
            [_guardNames addObject:[SQLManager deviceNameByDeviceID:guardId]];
        }

    }
    return _guardNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - %@",roomName,guardType]];
    
    self.deviceid = [SQLManager singleDeviceWithCatalogID:doorclock byRoom:self.roomID];
    
    [self.switcher setImage:[UIImage imageNamed:@"clock_open_pressed"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [[self.switcher rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         NSData *data = [[DeviceInfo defaultManager] toogle:0x01 deviceID:self.deviceid];
         SocketManager *sock=[SocketManager defaultManager];
         [sock.socket writeData:data withTimeout:1 tag:1];
     }];

    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01){
        //self.switchView.on = proto.action.state;
    }
    if (tag==0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            //self.switchView.on=proto.action.state;
        }
    }
}
    
#pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     id theSegue = segue.destinationViewController;
     [theSegue setValue:self.deviceid forKey:@"deviceid"];
 }

@end
