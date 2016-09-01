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
#import "ProtocolManager.h"
#import "DeviceManager.h"

@interface GuardController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedGuard;
@property (nonatomic,strong) UILabel *label;

- (IBAction)selectedTypeOfGuard:(UISegmentedControl *)sender;

@end

@implementation GuardController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.title = @"门禁";
    if(self.roomID)
    {
        self.deviceid = [DeviceManager deviceIDWithRoomID:self.roomID withType:@"智能门锁"];

    }
    

    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.switchView]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.switchView.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    EntranceGuard *device=[[EntranceGuard alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setUnlock: self.switchView.isOn];
    
    Scene *scene=[[Scene alloc] initWhithoutSchedule];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setRoomID:self.roomID];
    [scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device withId:device.deviceID];
    [scene setDevices:devices];
    
    [[SceneManager defaultManager] addScenen:scene withName:nil withPic:@""];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (proto.masterID != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        NSString *devID=[DeviceManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID) masterID:[[DeviceInfo defaultManager] masterID]];
        if ([devID intValue]==[self.deviceid intValue]) {
            self.switchView.on=proto.action.state;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 30)];
    
   [cell.contentView addSubview:label];
    if(indexPath.row == 0)
    {
        self.label = label;
        label.text = @"大门";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = self.switchView;
        if ([self.sceneid intValue]>0) {
            
            Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
            for(int i=0;i<[scene.devices count];i++)
            {
                if ([[scene.devices objectAtIndex:i] isKindOfClass:[EntranceGuard class]]) {
                    self.switchView.on=((EntranceGuard*)[scene.devices objectAtIndex:i]).unlock;
                }
            }
        }
        [self.switchView addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
        
    }else if(indexPath.row == 1){
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        label.text =  @"详细信息";
    }
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


- (IBAction)selectedTypeOfGuard:(UISegmentedControl *)sender {
    
    if(0 == sender.selectedSegmentIndex)
    {
        self.label.text = @"大门";
    }else if( 1 == sender.selectedSegmentIndex)
    {
        self.label.text = @"侧门";
    } else {
        self.label.text = @"车库";
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

-(void) dealloc
{
    [self.timer invalidate];
}

@end
