//
//  PluginViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PluginViewController.h"
#import "SocketManager.h"
#import "AsyncUdpSocket.h"
#import "PackManager.h"
#import "PluginCell.h"
#import "SQLManager.h"
#import "SceneManager.h"
#import "Plugin.h"

@interface PluginViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) PluginCell *cell;
@property (nonatomic,strong) NSMutableArray *plugNames;
@property (nonatomic,strong) NSMutableArray *plugDeviceIds;
@end

@implementation PluginViewController


-(NSMutableArray *)plugDeviceIds
{
   if(!_plugDeviceIds)
   {
       _plugDeviceIds = [NSMutableArray array];
       if(self.sceneid > 0 && !self.isAddDevice)
       {
           NSArray *plugArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
           for(int i = 0; i < plugArr.count; i++)
           {
               NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[plugArr[i] intValue]];
               if([typeName isEqualToString:DEVICE_TYPE])
               {
                   [_plugDeviceIds addObject:plugArr[i]];
               }
               
           }
       }else if(self.roomID > 0)
       {
           [_plugDeviceIds addObjectsFromArray:[SQLManager getDeviceByTypeName:DEVICE_TYPE andRoomID:self.roomID]];
       }else{
           [_plugDeviceIds addObject:self.deviceid];
       }
   }
    return _plugDeviceIds;
}
-(NSMutableArray *)plugNames
{
    if(!_plugNames)
    {
        _plugNames = [NSMutableArray array];
        for(int i = 0; i < self.plugDeviceIds.count; i++)
        {
            int plugId = [self.plugDeviceIds[i] intValue];
            NSString *name = [SQLManager deviceNameByDeviceID:plugId];
            [_plugNames addObject:name];
        }
    }
    return _plugNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self initPlugin];
    //[self initHomekitPlugin];
    [self setupSegment];
    
    self.scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
}
-(void)setupSegment
{
    if(self.plugNames == nil || self.plugNames.count == 0)
    {
        return;
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.plugNames.count; i++)
    {
        [self.segment insertSegmentWithTitle:self.plugNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [ self.plugDeviceIds objectAtIndex:self.segment.selectedSegmentIndex];
    
}
-(void)initHomekitPlugin
{
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
    
    self.devices=[NSMutableArray new];
}

- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager
{
    if (manager.primaryHome) {
        self.primaryHome = manager.primaryHome;
        self.primaryHome.delegate = self;
        
        for (HMAccessory *accessory in self.homeManager.primaryHome.accessories) {
            for (HMService *service in accessory.services) {
                if ([service.serviceType isEqualToString:HMServiceTypeOutlet]) {
                    //self.deviceLabel.text=service.name;
                    [self.devices addObject: [NSString stringWithFormat:@"%@(浇花)", service.name]];
                    for (HMCharacteristic *characterstic in service.characteristics) {
                        if ([characterstic.characteristicType isEqualToString:HMCharacteristicTypePowerState]) {
                            //self.powerSwitch.on=[characterstic.value boolValue];
                            self.characteristic=characterstic;
                        }
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}

-(void)initPlugin
{
    self.devices=[NSMutableArray new];
    [[SocketManager defaultManager] connectUDP:4156 delegate:self];
}

#pragma mark  - UDP delegate
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onUdpSocket:%@",data);
    [self handleUDP:data];
    return YES;
}

-(void)handleUDP:(NSData *)data
{
    NSData *ip=[data subdataWithRange:NSMakeRange(8, 4)];
    
    
    SocketManager *sock=[SocketManager defaultManager];
    [sock initTcp:[PackManager NSDataToIP:ip] port:1234 delegate:self];
    
    [self sendCmd:nil];
}

-(IBAction)sendCmd:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    NSString *cmd=@"fe000001000000000100ff";
    [sock.socket writeData:[PackManager dataFormHexString:cmd] withTimeout:-1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:1];
}

-(void)discoveryDevice:(NSData *)data
{
    [self.devices removeAllObjects];
    //fe01 0001 0016 0002 313710c8a5a505004b1200 98831069354304004b1200 de00ff
    NSData *length=[data subdataWithRange:NSMakeRange(6, 2)];
    for (int i; i<[PackManager dataToUInt16:length]; i++) {
        NSData *addr=[data subdataWithRange:NSMakeRange(8+11*i, 2)];
        //NSData *macAddr=[data subdataWithRange:NSMakeRange(11+11*i, 2)];
        [self.devices addObject:addr];//[NSString stringWithFormat:@"%ld",[PackManager NSDataToUInt:addr] ]];
    }
    [self.tableView reloadData];
}

-(IBAction)switchHomekitDevice:(id)sender
{

        if ([self.characteristic.characteristicType isEqualToString:HMCharacteristicTypeTargetLockMechanismState]  || [self.characteristic.characteristicType isEqualToString:HMCharacteristicTypePowerState]) {
            
            BOOL changedLockState = ![self.characteristic.value boolValue];
            
            [self.characteristic writeValue:[NSNumber numberWithBool:changedLockState] completionHandler:^(NSError *error){
                
                if(error != nil){
                    NSLog(@"error in writing characterstic: %@",error);
                }
            }];
        }
}

-(IBAction)switchDevice:(id)sender{
    UISwitch *sw=(UISwitch *)sender;
    /*
    NSString *cmd=@"FE00000000040001";//
    NSMutableData *data=[NSMutableData new];
    [data appendData:[PackManager dataFormHexString:cmd]];
    Byte array[] = {0x00};
    if (sw.on) {
        array[0] = 0x01;
    }
    [data appendBytes:array length:1];
    NSData *addr=[self.devices objectAtIndex:sw.tag];
    [data appendData:addr];
    NSString *tail=@"011e00ff";
    [data appendData:[PackManager dataFormHexString:tail]];
     */
    NSData *data=[[DeviceInfo defaultManager] toogle:sw.on deviceID:_deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:-1 tag:1];
    
}

-(IBAction)save:(id)sender
{
    [self switchDevice:sender];
    
    UISwitch *sw=(UISwitch *)sender;
    Plugin *device=[[Plugin alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setSwitchon: sw.isOn];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}

#pragma mark  - TCP delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    NSLog(@"data:%@,tag:%ld",data,tag);
    if (tag==1) {
        [self discoveryDevice:data];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && [self.plugNames count]>0)
    {
        static NSString *CellIdentifier = @"PluginCell";
        PluginCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        self.cell = cell;
        cell.label.text = self.plugNames[indexPath.row];
        
        cell.power.tag=indexPath.row;
        //cell.power.on=[self.characteristic.value boolValue];
        [cell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
        return  cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"recell"];
            
        }
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 30)];
        [cell.contentView addSubview:label];
        label.text = @"详细信息";
        return cell;

    }
   
}

- (IBAction)selectedSingProduct:(UISegmentedControl *)sender {
    
    self.cell.label.text = self.devices[sender.selectedSegmentIndex];
    self.deviceid = [self.plugDeviceIds objectAtIndex: self.segment.selectedSegmentIndex];
    [self.tableView reloadData];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[SocketManager defaultManager] cutOffSocket];
}

@end
