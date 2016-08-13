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

@interface CurtainController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCurtain;
- (IBAction)selectedTypeOfCurtain:(UISegmentedControl *)sender;

@end

@implementation CurtainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=@"窗帘";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cell = [[[NSBundle mainBundle] loadNibNamed:@"CurtainTableViewCell" owner:self options:nil] lastObject];
    self.cell.slider.continuous = NO;
    [self.cell.slider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.cell.open addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.cell.close addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Curtain class]]) {
                self.cell.slider.value=((Curtain*)[scene.devices objectAtIndex:i]).openvalue/100.0;
            }
        }
    }
    
    
}

-(IBAction)save:(id)sender
{
    ProtocolManager *manager=[ProtocolManager defaultManager];
    if ([sender isEqual:self.cell.slider]) {
        NSString *key=[NSString stringWithFormat:@"location_%@",self.deviceid];
        NSData* daty = [PackManager dataFormHexString:[manager queryDeviceStates:key]];
        
        uint8_t cmd=[PackManager dataToUint:daty];
        NSData *data=[[DeviceInfo defaultManager] roll:cmd deviceID:self.deviceid value:self.cell.slider.value * 100];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:2];
    }
    
    if ([sender isEqual:self.cell.open]) {
        NSData *data=[[DeviceInfo defaultManager] open:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:2];
    }
    
    if ([sender isEqual:self.cell.close]) {
        NSData *data=[[DeviceInfo defaultManager] close:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:2];
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
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device withId:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:@"" withPic:@""];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    
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
    if( 0 == sender.selectedSegmentIndex)
    {
       self.cell.label.text = @"前窗";
    }else if( 1 == sender.selectedSegmentIndex)
        {
            self.cell.label.text = @"侧窗";
        }else
            self.cell.label.text = @"落地窗";
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
