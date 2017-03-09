//
//  IphoneAirController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneAirController.h"
#import "RulerView.h"
#import "SQLManager.h"
#import "SceneManager.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "Aircon.h"

@interface IphoneAirController ()<RulerViewDatasource, RulerViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet RulerView *thermometerView;
@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;
@property (weak, nonatomic) IBOutlet UILabel *wetLabel;
@property (weak, nonatomic) IBOutlet UILabel *pmLabel;
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;
@property (weak, nonatomic) IBOutlet UITableView *paramView;
@property (weak, nonatomic) IBOutlet UIView *CoverView;

@property (weak, nonatomic) IBOutlet UISwitch *Myswitch;

@end

@implementation IphoneAirController
- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager deviceIDWithRoomID:self.roomID withType:@"空调"];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.params=@[@[@"制热",@"制冷",@"送风",@"除湿"],@[@"向上",@"向下"],@[@"高速",@"中速",@"低速",@"自动"],@[@"0.5H",@"1H",@"2H",@"3H"]];
    self.paramView.scrollEnabled=NO;
    self.paramView.delegate = self;
    self.paramView.dataSource = self;
    self.paramView.hidden = YES;
    self.CoverView.hidden = YES;
    self.CoverView.alpha = 0.9;
    
//
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Action:)];
////    [self.CoverView addGestureRecognizer:tap];
    
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Aircon class]]) {
                
                self.showTemLabel.text = [NSString stringWithFormat:@"%d°C", ((Aircon*)[_scene.devices objectAtIndex:i]).temperature];
                self.currentMode=((Aircon*)[_scene.devices objectAtIndex:i]).mode;
                self.currentLevel=((Aircon*)[_scene.devices objectAtIndex:i]).WindLevel;
                self.currentDirection=((Aircon*)[_scene.devices objectAtIndex:i]).Windirection;
                self.currentTiming=((Aircon*)[_scene.devices objectAtIndex:i]).timing;
            }
        }
    }
    
    self.thermometerView.datasource = self;
    self.thermometerView.delegate = self;
    [self.thermometerView updateCurrentValue:24];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
      [self.Myswitch addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];

}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.Myswitch]) {
        //        NSData *data=[[DeviceInfo defaultManager] toogle:self.switchView.isOn deviceID:self.deviceid];
        NSData * data = [[DeviceInfo defaultManager] toogleAirCon:self.Myswitch.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    //    Amplifier *device=[[Amplifier alloc] init];
    Aircon * device = [[Aircon alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.Myswitch.isOn];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}

-(IBAction)Iphonesave:(id)sender
{
    
    Aircon *device = [[Aircon alloc]init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setMode:self.currentMode];
    [device setWindLevel:self.currentLevel];
    [device setWindirection:self.currentDirection];
    [device setTiming:self.currentTiming];
    
    [device setTemperature:[self.showTemLabel.text intValue]];
    
    
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
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01){
        self.Myswitch.on = proto.action.state;
    }
    if (tag==0) {
        if (proto.action.state==0x7A) {
            self.showTemLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.wetLabel.text = valueString;
        }
        if (proto.action.state==0x7F) {
            NSString *valueString = [NSString stringWithFormat:@"%d ug/m",proto.action.RValue];
            self.pmLabel.text = valueString;
        }
        if (proto.action.state==0x7E) {
            NSString *valueString = [NSString stringWithFormat:@"%d db",proto.action.RValue];
            self.noiseLabel.text = valueString;
        }
    }
}
#pragma mark - RulerViewDelegate
- (void)rulerView:(RulerView *)rulerView didChangedCurrentValue:(CGFloat)currentValue {
    NSInteger value = round(currentValue);
    NSString *valueString = [NSString stringWithFormat:@"%d ℃", (int)value];
    self.showTemLabel.text = valueString;

    NSData * data = [[DeviceInfo defaultManager] changeTemperature:0x6A deviceID:self.deviceid value:[self.showTemLabel.text intValue]];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:2];
//    [self save:nil];
}
- (IBAction)changeButton:(UIButton *)sender {

    self.paramView.hidden = NO;
    self.CoverView.hidden = NO;
    if ([self.sceneid intValue]>0) {
        if (self.currentButton == ZXPMode) {
            self.currentIndex = self.currentMode - 1;
        }
        if (self.currentButton == ZXPLevel) {
            self.currentIndex = self.currentLevel - 1;
        }
        if (self.currentButton == ZXPDirection) {
            self.currentIndex = self.currentDirection - 1;
        }
        if (self.currentButton == ZXPTiming) {
            self.currentIndex = self.currentTiming - 1;
        }
    }
    self.currentButton=(int)((UIButton *)sender).tag;
    [self.paramView reloadData];
    
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.params[self.currentButton] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text= [self.params[self.currentButton] objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==self.currentIndex){
        return UITableViewCellAccessoryCheckmark;
    }
    else{
        return UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.CoverView.hidden = YES;
    self.paramView.hidden = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row==self.currentIndex){
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.currentIndex
                                                   inSection:0];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    self.currentIndex=(int)indexPath.row;
    uint8_t cmd=0;
    if (self.currentButton == ZXPMode) {
        self.currentMode = self.currentIndex+1;
        if (self.currentIndex==0) {
            cmd = 0x39+self.currentIndex;
        }else{
            cmd = 0x3F+self.currentIndex;
        }
    }
    if (self.currentButton == ZXPLevel) {
        self.currentLevel = self.currentIndex+1;
        cmd = 0x35+self.currentIndex;
    }
    if (self.currentButton == ZXPDirection) {
        self.currentDirection = self.currentIndex+1;
        cmd = 0x43+self.currentIndex;
    }
    if (self.currentButton == ZXPTiming) {
        self.currentTiming = self.currentIndex+1;
    }
    NSData *data=[self createCmd:cmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [self Iphonesave:nil];
}

-(NSData *)createCmd:(uint8_t) cmd
{
    return [[DeviceInfo defaultManager] changeMode:cmd
                                          deviceID:self.deviceid];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.thermometerView reloadView];
}

#pragma mark - Item setting
- (RulerItemModel *)rulerViewRulerItemModel:(RulerView *)rulerView {
    RulerItemModel *itemModel = [[RulerItemModel alloc] init];
    
    itemModel.itemLineColor = [UIColor blackColor];
    itemModel.itemMaxLineWidth = 30;
//    itemModel.itemMinLineWidth = 20;
//    itemModel.itemMiddleLineWidth = 24;
    itemModel.itemLineHeight = 1;
    itemModel.itemNumberOfRows = 16;
    itemModel.itemHeight = 30;
    itemModel.itemWidth = itemModel.itemMaxLineWidth;
    
    return itemModel;
}


#pragma mark - Ruler setting
- (CGFloat)rulerViewMaxValue:(RulerView *)rulerView {
    return 32;
}

- (CGFloat)rulerViewMinValue:(RulerView *)rulerView {
    return 16;
}

- (UIFont *)rulerViewTextLabelFont:(RulerView *)rulerView {
    return [UIFont systemFontOfSize:11.f];
}

- (UIColor *)rulerViewTextLabelColor:(RulerView *)rulerView {
    return [UIColor magentaColor];
}

- (CGFloat)rulerViewTextlabelLeftMargin:(RulerView *)rulerView {
    return 4.f;
}

- (CGFloat)rulerViewItemScrollViewDecelerationRate:(RulerView *)rulerView {
    return 0;
}

#pragma mark - Left tag setting
- (CGFloat)rulerViewLeftTagLineWidth:(RulerView *)rulerView {
    return 50;
}

- (CGFloat)rulerViewLeftTagLineHeight:(RulerView *)rulerView {
    return 2;
}

- (UIColor *)rulerViewLeftTagLineColor:(RulerView *)rulerView {
    return [UIColor redColor];
}

- (CGFloat)rulerViewLeftTagTopMargin:(RulerView *)rulerView {
    return 300;
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
