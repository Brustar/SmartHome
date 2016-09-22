//
//  AmplifierController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AmplifierController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Amplifier.h"
#import "SceneManager.h"
#import "PackManager.h"

@interface AmplifierController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) DetailTableViewCell *cell;
@property (nonatomic,strong) NSMutableArray *amplifierNames;
@property (nonatomic,strong) NSMutableArray *amplifierIDArr;
@end

@implementation AmplifierController

-(NSMutableArray *)amplifierIDArr
{
    if(!_amplifierIDArr)
    {
        _amplifierIDArr = [NSMutableArray array];
        
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *amplifiers = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i<amplifiers.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[amplifiers[i] intValue]];
                if([typeName isEqualToString:@"功放"])
                {
                    [_amplifierIDArr addObject:amplifiers[i]];
                }

            }
        }else if(self.roomID)
        {
            [_amplifierIDArr addObjectsFromArray:[SQLManager getDeviceByTypeName:@"功放" andRoomID:self.roomID]];
        }else{
            [_amplifierIDArr addObject:self.deviceid];
        }
        
    }
    return _amplifierIDArr;
}

-(NSMutableArray *)amplifierNames
{
    if(!_amplifierNames)
    {
        _amplifierNames = [NSMutableArray array];
        for(int i = 0; i < self.amplifierIDArr.count; i++)
        {
            int amplifierID = [self.amplifierIDArr[i] intValue];
            [_amplifierNames addObject:[SQLManager deviceNameByDeviceID:amplifierID]];
        }
    }
    return _amplifierNames;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功放";
    
    [self setupSegmenAmplifier];
    
    // Do any additional setup after loading the view.
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.switchView]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.switchView.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.switchView.isOn];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (proto.masterID != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID) masterID:[[DeviceInfo defaultManager] masterID]];
        if ([devID intValue]==[self.deviceid intValue]) {
            self.switchView.on=proto.action.state;
        }
    }
}

-(void)setupSegmenAmplifier
{
    if(self.amplifierNames == nil)
    {
        return;
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.amplifierNames.count; i++)
    {
        [self.segment insertSegmentWithTitle:self.amplifierNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [self.amplifierIDArr objectAtIndex:self.segment.selectedSegmentIndex];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        self.cell = cell;
        cell.label.text = self.amplifierNames[self.segment.selectedSegmentIndex];
        
        
        self.switchView = cell.power;//[[UISwitch alloc] initWithFrame:CGRectZero];
        if ([self.sceneid intValue]>0) {
            
            _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
            for(int i=0;i<[_scene.devices count];i++)
            {
                if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Amplifier class]]) {
                    cell.power.on=((Amplifier *)[_scene.devices objectAtIndex:i]).waiting;
                }
            }
        }
        [cell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"recell"];
            
        }
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 30)];
        [cell.contentView addSubview:label];
        label.text = @"详细信息";
        return cell;
    }
    
    
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

- (IBAction)selectedAmplifier:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.cell.label.text = self.amplifierNames[segment.selectedSegmentIndex];
    self.deviceid=[self.amplifierIDArr objectAtIndex:self.segment.selectedSegmentIndex];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
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
