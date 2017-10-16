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
#import "SocketManager.h"
#import "SQLManager.h"

@interface CurtainController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCurtain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeftConstraint;
@property (nonatomic,strong) NSMutableArray *curNames;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewRightConstraint;
@property (nonatomic,strong) NSMutableArray *curtainIDArr;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableLeft;

@end

@implementation CurtainController

-(NSMutableArray *)curtainIDArr
{
    if(!_curtainIDArr)
    {
        _curtainIDArr = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *curtainArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i <curtainArr.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[curtainArr[i] intValue]];
                if([typeName isEqualToString:@"窗帘"])
                {
                    [_curtainIDArr addObject:curtainArr[i]];
                }
            }

        }else if(self.roomID){
            [_curtainIDArr addObjectsFromArray:[SQLManager getDeviceBysubTypeid:CURTAIN_DEVICE_TYPE andRoomID:self.roomID]];
        }else{
            [_curtainIDArr addObject:self.deviceid?self.deviceid:@"0"];
        }
        
        
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
            [_curNames addObject:[SQLManager deviceNameByDeviceID:curtainID]];
        }
        
    }
    return _curNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostType = [[UD objectForKey:@"HostType"] integerValue];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 窗帘",roomName]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainC4TableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainC4TableViewCell"];//C4窗帘
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    for (id did in self.curtainIDArr) {
        //查询设备状态
        NSData *data = [[DeviceInfo defaultManager] query:did];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    [self.tableView reloadData];
    
    if (ON_IPAD) {
        self.tableLeft.constant = self.tableRight.constant = 100;
    }
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

-(IBAction) changeCurtain:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    long tag = slider.tag;
    NSString *deviceid = [self.curtainIDArr objectAtIndex:tag-100];
    NSData *data=[[DeviceInfo defaultManager] roll:slider.value * 100 deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:2];
}

-(IBAction) toggleCurtain:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    long tag = btn.tag;
    
    UISlider *slider = [self.tableView viewWithTag:100+tag];
    
    NSString *deviceid = [self.curtainIDArr objectAtIndex:tag];
    btn.selected = !btn.selected;
    if (btn.selected) {
        slider.value=1;
        [btn setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
    }else{
        slider.value=0;
        [btn setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateNormal];
    }
    SocketManager *sock=[SocketManager defaultManager];
    NSData *data=[[DeviceInfo defaultManager] toogle:btn.selected deviceID:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:2];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    int devID = [[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)] intValue];
    if (![self.curtainIDArr containsObject:@(devID)]) {
        return;
    }
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (_hostType == 0) {  //Crestron
    
      CurtainTableViewCell *cell = [self.tableView viewWithTag:devID];
    
    
    //同步设备状态
    if(proto.cmd == 0x01){
         cell.open.selected = proto.action.state == PROTOCOL_ON;
    }
    
    if (tag==0 && (proto.action.state == 0x2A || proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON)) {
        
        if (devID==[self.deviceid intValue]) {
            cell.slider.value=proto.action.RValue/100.0;
            if (proto.action.state == PROTOCOL_ON) {
                cell.slider.value=1;
            }
        }
    }
        
        
  }
    
    else { //C4
        CurtainC4TableViewCell *cell = [self.tableView viewWithTag:devID];
        
        
        //同步设备状态
        if(proto.cmd == 0x01){
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {
                cell.switchBtn.selected = proto.action.state;
            }
            
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.curtainIDArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_hostType == 0) {  //Crestron
        CurtainTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CurtainTableViewCell" owner:self options:nil] lastObject];
        cell.slider.continuous = NO;
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.label.text = [self.curNames objectAtIndex:indexPath.row];
        cell.deviceid = [self.curtainIDArr objectAtIndex:indexPath.row];
        cell.tag = [cell.deviceid integerValue];
        cell.slider.tag = 100+indexPath.row;
        cell.open.tag = indexPath.row;
        cell.AddcurtainBtn.hidden = YES;
        cell.curtainContraint.constant = 10;
        return cell;
    }else if (_hostType == 1) {   //C4
        
        CurtainC4TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurtainC4TableViewCell" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = [self.curNames objectAtIndex:indexPath.row];
        cell.deviceid = [self.curtainIDArr objectAtIndex:indexPath.row];
        cell.tag = [cell.deviceid integerValue];
        cell.switchBtn.tag = indexPath.row;
        cell.addBtn.hidden = YES;
        cell.switchBtnTrailingConstraint.constant = 10;
        return cell;
    }
    
    return nil;
}

//设置表头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_hostType == 0) {  //Crestron
        
        if (ON_IPAD) {
            return 150.0f;
        }else{
            return 100;
        }
        
    }else if (_hostType == 1) {   //C4
        
        if (ON_IPAD) {
            return 100.0f;
        }else{
            return 100;
        }
    }
    
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if(indexPath.row == 1)
//    {
//        [self performSegueWithIdentifier:@"detail" sender:self];
//    }
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
