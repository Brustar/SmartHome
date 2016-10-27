 //
//  GuardController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define guardType @"智能门锁"

#import "GuardController.h"
#import "EntranceGuard.h"
#import "Scene.h"
#import "SceneManager.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SQLManager.h"



@interface GuardController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedGuard;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSMutableArray *guardNames;
@property (nonatomic,strong) NSMutableArray *guardIDs;

- (IBAction)selectedTypeOfGuard:(UISegmentedControl *)sender;

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
            [_guardIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:guardType andRoomID:self.roomID]];
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
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.title = guardType;
    
    [self setupSegmentGuard];

    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

-(void)setupSegmentGuard
{
    if(self.guardNames == nil || self.guardNames.count == 0)
    {
        return;
    }
    [self.segmentedGuard removeAllSegments];
    for(int i = 0; i < self.guardNames.count;i++)
    {
        [self.segmentedGuard insertSegmentWithTitle:self.guardNames[i] atIndex:i animated:NO];
    }
    self.segmentedGuard.selectedSegmentIndex = 0;
    self.deviceid = [self.guardIDs objectAtIndex:self.segmentedGuard.selectedSegmentIndex];
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
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 150, 30)];
    
   [cell.contentView addSubview:label];
    if(indexPath.row == 0)
    {
        self.label = label;
        label.text = self.guardNames[self.segmentedGuard.selectedSegmentIndex];
//        label.text = @"智能门锁";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = self.switchView;
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        if ([self.sceneid intValue]>0) {
            for(int i=0;i<[_scene.devices count];i++)
            {
                if ([[_scene.devices objectAtIndex:i] isKindOfClass:[EntranceGuard class]]) {
                    self.switchView.on=((EntranceGuard*)[_scene.devices objectAtIndex:i]).unlock;
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
    
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.label.text = self.guardNames[segment.selectedSegmentIndex];
    self.deviceid=[self.guardIDs objectAtIndex:self.segmentedGuard.selectedSegmentIndex];
    [self.tableView reloadData];
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
