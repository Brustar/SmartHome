//
//  CurtainController.m
//  SmartHome
//
//  Created by Brustar on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CurtainController.h"
#import "CurtainTableViewCell.h"
#import "PackManager.h"
#import "ProtocolManager.h"
#import "SocketManager.h"
#import "DeviceManager.h"

@interface CurtainController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCurtain;
- (IBAction)selectedTypeOfCurtain:(UISegmentedControl *)sender;

@property (nonatomic,strong) NSMutableArray *curNames;

@property (nonatomic,strong) NSMutableArray *curtainIDArr;
@end

@implementation CurtainController


-(NSMutableArray *)curtainIDArr
{
    if(!_curtainIDArr)
    {
        _curtainIDArr = [NSMutableArray array];
        [_curtainIDArr addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"开合帘" andRoomID:self.roomID]];
         [_curtainIDArr addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"卷帘" andRoomID:self.roomID]];
        
    }
    return _curtainIDArr;
}

-(NSMutableArray *)curNames
{
    if(!_curNames)
    {
        _curNames = [NSMutableArray array];
        for(int i = 0; i < self.curtainIDArr.count; i++)
        {
            int curtainID = [self.curtainIDArr[i] intValue];
            [_curNames addObject:[DeviceManager deviceNameByDeviceID:curtainID]];
        }
        
    }
    return _curNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"窗帘";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cell = [[[NSBundle mainBundle] loadNibNamed:@"CurtainTableViewCell" owner:self options:nil] lastObject];
    self.cell.slider.continuous = NO;
    [self.cell.slider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.cell.open addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.cell.close addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.sceneid intValue] >0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Curtain class]]) {
                self.cell.slider.value=((Curtain*)[scene.devices objectAtIndex:i]).openvalue/100.0;
            }
        }
    }
    
    [self setupSegmentCurtain];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

- (void)setupSegmentCurtain
{
    
    if (self.curNames == nil) {
        return;
    }
    
    [self.segmentCurtain removeAllSegments];
    
    for ( int i = 0; i < self.curNames.count; i++) {
        [self.segmentCurtain insertSegmentWithTitle:self.curNames[i] atIndex:i animated:NO];
        
       
        
       
    }
    
    self.segmentCurtain.selectedSegmentIndex = 0;
    self.deviceid=[self.curtainIDArr objectAtIndex:self.segmentCurtain.selectedSegmentIndex];
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.cell.slider]) {
        NSData *data=[[DeviceInfo defaultManager] roll:self.cell.slider.value * 100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }
    
    if ([sender isEqual:self.cell.open]) {
        self.cell.slider.value=1;
        NSData *data=[[DeviceInfo defaultManager] open:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }
    
    if ([sender isEqual:self.cell.close]) {
        self.cell.slider.value=0;
        NSData *data=[[DeviceInfo defaultManager] close:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }
    
    
    Curtain *device=[[Curtain alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setOpenvalue:self.cell.slider.value * 100];
    
    if ([sender isEqual:self.cell.open]) {
        [device setOpenvalue:100];
    }
    
    if ([sender isEqual:self.cell.close]) {
        [device setOpenvalue:0];
    }
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    
    [scene setStartTime:@""];
    [scene setWeekValue:@""];
    [scene setAstronomicalTime:@""];
    [scene setWeekRepeat:0];
    [scene setRoomName:@""];
    [scene setSceneName:@""];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device withId:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:nil withPic:@""];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (tag==0 && proto.action.state == 0x2A) {
        NSString *devID=[DeviceManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID) masterID:[[DeviceInfo defaultManager] masterID]];
        if ([devID intValue]==[self.deviceid intValue]) {
            self.cell.slider.value=proto.action.RValue/100.0;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.cell.label.text = self.curNames[self.segmentCurtain.selectedSegmentIndex];
        return self.cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 30)];
    [cell.contentView addSubview:label];
    label.text = @"详细信息";
    
    return cell;
  
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}

- (IBAction)selectedTypeOfCurtain:(UISegmentedControl *)sender {
    self.cell.label.text = self.curNames[sender.selectedSegmentIndex];
    self.deviceid=[self.curtainIDArr objectAtIndex:self.segmentCurtain.selectedSegmentIndex];
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

@end
