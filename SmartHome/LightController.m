//
//  Light.m
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LightController.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "DeviceManager.h"
#import "Device.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface LightController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favButt;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) CGFloat brightValue;

@property (nonatomic,strong) NSMutableArray *lIDs;
@property (nonatomic,strong) NSMutableArray *lNames;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentLight;

- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender;

@end

@implementation LightController

-(NSMutableArray *)lIDs
{
    if(!_lIDs)
    {
        _lIDs = [NSMutableArray array];
       
           if(self.sceneid > 0)
           {
           // NSArray *lightArr = [DeviceManager getDeviceIDWithRoomID:self.roomID sceneID:[self.sceneid intValue]];
               NSArray *lightArr = [DeviceManager getDeviceIDsBySeneId:[self.sceneid intValue]];
               for(int i = 0; i <lightArr.count; i++)
               {
                   NSString *typeName = [DeviceManager deviceTypeNameByDeviceID:[lightArr[i] intValue]];
                   if([typeName isEqualToString:@"灯光"])
                   {
                       [_lIDs addObject:lightArr[i]];
                   }
               }
               
               
           }else if(self.roomID > 0){
               [_lIDs addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"开关灯" andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"调光灯" andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"调色灯" andRoomID:self.roomID]];

           }else{
               [_lIDs addObject:self.deviceid];
           }
        
        }
    return _lIDs;
}

-(NSMutableArray *)lNames
{
    if(!_lNames)
    {
        _lNames = [NSMutableArray array];
        for(int i = 0; i < self.lIDs.count; i++)
        {
            int lID = [self.lIDs[i] intValue];
            NSString *name = [DeviceManager deviceNameByDeviceID:lID];
            [_lNames addObject:name];
        }
    }
    return _lNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailCell = [[[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil] lastObject];
    self.detailCell.bright.continuous = NO;
    [self.detailCell.bright addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    

    [self.detailCell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    self.cell = [[[NSBundle mainBundle] loadNibNamed:@"ColourTableViewCell" owner:self options:nil] lastObject];
    [self setupSegmentLight];
    
    self.scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        _favButt.enabled=YES;
        
        [self syncUI];
    }
    
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLight:) name:@"light" object:nil];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

-(void) syncUI
{
    for(id device in self.scene.devices)
    {
        if ([device isKindOfClass:[Light class]] && ((Light*)device).deviceID == [self.deviceid intValue]) {
            self.detailCell.bright.value=((Light*)device).brightness/100.0;
            self.detailCell.power.on=((Light*)device).isPoweron;
            if ([((Light*)device).color count]>2) {
                self.cell.colourView.backgroundColor=[UIColor colorWithRed:[[((Light*)device).color firstObject] intValue]/255.0 green:[[((Light*)device).color objectAtIndex:1] intValue]/255.0  blue:[[((Light*)device).color lastObject] intValue]/255.0  alpha:1];
            }
        }
    }
}

-(IBAction)syncLight:(id)sender
{
    NSNotification * notice = (NSNotification *)sender;
    NSDictionary *dic= [notice userInfo];
    int state = [dic[@"state"] intValue];
    if (state == PROTOCOL_OFF || state == PROTOCOL_ON) {
        self.detailCell.power.on = (bool)state;
    }
    if (state == 0x0a) {
        self.detailCell.bright.value=[dic[@"r"] intValue];
    }
    if (state == 0x0b) {
        self.cell.colourView.backgroundColor=[UIColor colorWithRed:[dic[@"r"] intValue]/255.0 green:[dic[@"g"] intValue]/255.0  blue:[dic[@"b"] intValue]/255.0  alpha:1];
    }
}

- (void)setupSegmentLight
{
    
    if (self.lNames == nil) {
        return;
    }
    
    [self.segmentLight removeAllSegments];
    
    for ( int i = 0; i < self.lNames.count; i++) {
        [self.segmentLight insertSegmentWithTitle:self.lNames[i] atIndex:i animated:NO];
    
    }
    
    self.segmentLight.selectedSegmentIndex = 0;
    self.deviceid = [self.lIDs objectAtIndex:self.segmentLight.selectedSegmentIndex];
}

- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([originColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    return @{@"R":@(r),
             @"G":@(g),
             @"B":@(b),
             @"A":@(a)};
}

-(IBAction)save:(id)sender
{
    NSString *etype = [DeviceManager getEType:[self.deviceid intValue]];
    
    if ([sender isEqual:self.detailCell.power]) {
        NSData *data=[[DeviceInfo defaultManager] toogleLight:self.detailCell.power.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        BOOL isOn = self.detailCell.power.isOn;
        
        if (isOn) {
            self.detailCell.bright.value = 1;
        } else {
            self.detailCell.bright.value = 0;
        }
        
        self.detailCell.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.detailCell.bright.value * 100)];
    }
    
    if (![etype isEqualToString:@"01"] && [sender isEqual:self.detailCell.bright]) {
        NSData *data=[[DeviceInfo defaultManager] changeBright:self.detailCell.bright.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }
    
    if ([etype isEqualToString:@"03"] && [sender isEqual:self.cell.colourView]) {
        UIColor *color = self.cell.colourView.backgroundColor;
        NSDictionary *colorDic = [self getRGBDictionaryByColor:color];
        int r = [colorDic[@"R"] floatValue] * 255;
        int g = [colorDic[@"G"] floatValue] * 255;
        int b = [colorDic[@"B"] floatValue] * 255;

        NSData *data=[[DeviceInfo defaultManager] changeColor:self.deviceid R:r G:g B:b];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:3];
    }
    
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron: self.detailCell.power.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.cell.colourView.backgroundColor];
    if (colors) {
        if ([etype isEqualToString:@"03"]) {
            [device setColor:colors];
        }
        [device setColor:@[]];
    }
    
    if (![etype isEqualToString:@"01"])
    {
        [device setBrightness:self.detailCell.bright.value*100];
    }

    
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
    
    if (tag == 0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON || proto.action.state == 0x0b || proto.action.state == 0x0a)) {
        NSString *devID=[DeviceManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID) masterID:[[DeviceInfo defaultManager] masterID]];
        if ([devID intValue]==[self.deviceid intValue]) {
            //创建一个消息对象
            NSNotification * notice = [NSNotification notificationWithName:@"light" object:nil userInfo:@{@"state":@(proto.action.state),@"r":@(proto.action.RValue),@"g":@(proto.action.G),@"b":@(proto.action.B)}];
            //发送消息
            [[NSNotificationCenter defaultCenter] postNotification:notice];
        }
    }
}

//将UIColor转换为RGB值
- (NSArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    int r = [[NSString stringWithFormat:@"%@",[RGBArr objectAtIndex:1]] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    int g = [[NSString stringWithFormat:@"%@",[RGBArr objectAtIndex:2] ] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    int b = [[NSString stringWithFormat:@"%@",[RGBArr objectAtIndex:3]] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
}

-(IBAction)changeColor:(id)sender
{
    HRSampleColorPickerViewController *controller= [[HRSampleColorPickerViewController alloc] initWithColor:self.cell.backgroundColor fullColor:NO];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setSelectedColor:(UIColor *)color
{

    self.cell.colourView.backgroundColor = color;
    [self save:nil];
}



#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *typeName = [DeviceManager lightTypeNameByDeviceID:[self.deviceid intValue]];
    if ([typeName isEqualToString:@"调色灯"]) {
        return 3;
    }
    return 2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *typeName = [DeviceManager lightTypeNameByDeviceID:[self.deviceid intValue]];
    
    if(indexPath.row == 0)
    {
        self.detailCell.label.text = self.lNames[self.segmentLight.selectedSegmentIndex];
        
        if ([typeName isEqualToString:@"开关灯"] || [typeName isEqualToString:@"调色灯"]) {
            self.detailCell.bright.hidden = YES;
            self.detailCell.lightImg.hidden = YES;
            self.detailCell.brightImg.hidden = YES;
            self.detailCell.power.hidden = NO;
            self.detailCell.valueLabel.hidden = YES;
        } else if ([typeName isEqualToString:@"调光灯"]) {
            self.detailCell.bright.hidden = NO;
            self.detailCell.lightImg.hidden = NO;
            self.detailCell.brightImg.hidden = NO;
            self.detailCell.power.hidden = NO;
            self.detailCell.valueLabel.hidden = NO;
        }
        
        self.detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.detailCell;
    }
    
    if (indexPath.row == 1 && [typeName isEqualToString:@"调色灯"]) {
        self.cell.lable.text = @"自定义颜色";
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
        self.cell.colourView.userInteractionEnabled=YES;
        [self.cell.colourView addGestureRecognizer:singleTap];
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

//设置cell行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *typeName = [DeviceManager lightTypeNameByDeviceID:[self.deviceid intValue]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1)
    {
        if([typeName isEqualToString:@"调色灯"])
            return;
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
    if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}

- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender {
    
    self.detailCell.label.text = self.lNames[sender.selectedSegmentIndex];
    self.deviceid = [self.lIDs objectAtIndex:self.segmentLight.selectedSegmentIndex];
    [self syncUI];
    [self.tableView reloadData];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"light" object:nil];
}
@end
