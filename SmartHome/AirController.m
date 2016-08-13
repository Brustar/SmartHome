//
//  AirController.m
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AirController.h"
#import "SceneManager.h"
#import "Aircon.h"
#import "RulerView.h"
#import "SocketManager.h"
#import "ProtocolManager.h"
#import "PackManager.h"

@interface AirController ()<RulerViewDatasource, RulerViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet RulerView *thermometerView;
@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;
@property (weak, nonatomic) IBOutlet UITableView *paramView;

@end

@implementation AirController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.params=@[@[@"制冷",@"制热",@"抽湿",@"自动"],@[@"向上",@"向下"],@[@"高风",@"中风",@"低风"],@[@"0.5H",@"1H",@"2H",@"3H"]];
    self.paramView.scrollEnabled=NO;
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Aircon class]]) {
                
                self.showTemLabel.text = [NSString stringWithFormat:@"%d°C", ((Aircon*)[scene.devices objectAtIndex:i]).temperature];
                self.currentMode=((Aircon*)[scene.devices objectAtIndex:i]).mode;
                self.currentLevel=((Aircon*)[scene.devices objectAtIndex:i]).WindLevel;
                self.currentDirection=((Aircon*)[scene.devices objectAtIndex:i]).Windirection;
                self.currentTiming=((Aircon*)[scene.devices objectAtIndex:i]).timing;
            }
        }
    }
    self.thermometerView.datasource = self;
    self.thermometerView.delegate = self;
    
    [self.thermometerView updateCurrentValue:24];
    SocketManager *sock=[SocketManager defaultManager];
    [sock initTcp:[IOManager tcpAddr] port:[IOManager tcpPort] mode:outDoor delegate:nil];
    
    NSString *cmd=@"ECFE22B800000000000000EA";
    [sock.socket writeData:[PackManager dataFormHexString:cmd] withTimeout:1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:1];
}

-(IBAction)save:(id)sender
{
    Aircon *device = [[Aircon alloc]init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setMode:self.currentMode];
    [device setWindLevel:self.currentLevel];
    [device setWindirection:self.currentDirection];
    [device setTiming:self.currentTiming];
    
    [device setTemperature:[self.showTemLabel.text intValue]];
    
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

-(IBAction)changeButton:(id)sender
{
    if ([self.sceneid intValue]>0) {
    if (self.currentButton == mode) {
        self.currentIndex = self.currentMode - 1;
    }
    if (self.currentButton == level) {
        self.currentIndex = self.currentLevel - 1;
    }
    if (self.currentButton == direction) {
        self.currentIndex = self.currentDirection - 1;
    }
    if (self.currentButton == timing) {
        self.currentIndex = self.currentTiming - 1;
    }
    }
    self.currentButton=(int)((UIButton *)sender).tag;
    [self.paramView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (self.currentButton == mode) {
        self.currentMode = self.currentIndex+1;
        self.actKey=@"mode";
    }
    if (self.currentButton == level) {
        self.currentLevel = self.currentIndex+1;
        self.actKey=@"speed";
    }
    if (self.currentButton == direction) {
        self.currentDirection = self.currentIndex+1;
        self.actKey=@"direction";
    }
    if (self.currentButton == timing) {
        self.currentTiming = self.currentIndex+1;
        self.actKey=@"timing";
    }
    NSData *data=[self createCmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:1];
    
    [self save:nil];
}

-(NSData *)createCmd
{
    NSString *key=[NSString stringWithFormat:@"%@_%@",self.actKey,self.deviceid];
    ProtocolManager *manager=[ProtocolManager defaultManager];
    NSArray *cmds=[[manager queryDeviceStates:key] componentsSeparatedByString:@","];
    
    NSData* data = [PackManager dataFormHexString:[cmds objectAtIndex:self.currentIndex]];
    
    uint8_t cmd=[PackManager dataToUint:data];
    
    return [[DeviceInfo defaultManager] changeMode:cmd
                                                  deviceID:key];
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

#pragma mark - RulerViewDelegate
- (void)rulerView:(RulerView *)rulerView didChangedCurrentValue:(CGFloat)currentValue {
    NSInteger value = round(currentValue);
    
    NSString *valueString = [NSString stringWithFormat:@"%d ℃", (int)value];
    
    self.showTemLabel.text = valueString;
    //[self save:nil];
}

#pragma mark - Item setting
- (RulerItemModel *)rulerViewRulerItemModel:(RulerView *)rulerView {
    RulerItemModel *itemModel = [[RulerItemModel alloc] init];
    
    itemModel.itemLineColor = [UIColor blackColor];
    itemModel.itemMaxLineWidth = 30;
    itemModel.itemMinLineWidth = 20;
    itemModel.itemMiddleLineWidth = 24;
    itemModel.itemLineHeight = 1;
    itemModel.itemNumberOfRows = 16;
    itemModel.itemHeight = 60;
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
@end