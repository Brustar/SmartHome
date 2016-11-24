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
    cell.slider.tag = indexPath.row;
    cell.Iphoneswitch.tag = indexPath.row;
    [cell.slider addTarget:self action:@selector(dimming:) forControlEvents:UIControlEventValueChanged];
    [cell.Iphoneswitch addTarget:self action:@selector(Iphoneswitch:) forControlEvents:UIControlEventValueChanged];
    return cell;
    
}
-(void)dimming:(UISlider *)slider
{
    
    NSString *deviceid = _lightArrs[slider.tag];
    
    NSData *data=[[DeviceInfo defaultManager] changeBright:slider.value*100 deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:2];
}
-(void)Iphoneswitch:(UISwitch *)switc
{

    NSString *deviceid = _lightArrs[switc.tag];
    NSData * data = [[DeviceInfo defaultManager] toogleLight:switc.on deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:2];
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
