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

@interface IphoneLightController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray * roomArrs;
@property (nonatomic,strong) NSArray * lightArrs;
@property (nonatomic,strong) NSString * deviceid;

@end

@implementation IphoneLightController

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
    
    _lightArrs = [SQLManager getDeviceByRoom:self.roomID];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lightArrs.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Device *device = [SQLManager getDeviceWithDeviceID:[_lightArrs[indexPath.row] intValue]];
    cell.LightNameLabel.text = device.name;
    cell.slider.continuous = NO;
    cell.deviceid = self.lightArrs[indexPath.row];
    
    return cell;
}


#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag == 0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON || proto.action.state == 0x0b || proto.action.state == 0x0a)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID) masterID:[[DeviceInfo defaultManager] masterID]];
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

    return 60;

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
