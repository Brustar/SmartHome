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
#import "SQLManager.h"

#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "ORBSwitch.h"
#import "UIView+Popup.h"
#import "STColorPicker.h"

static NSString *const menuCellIdentifier = @"rotationCell";

@interface LightController ()<UITableViewDelegate,UITableViewDataSource,YALContextMenuTableViewDelegate,ORBSwitchDelegate>

@property (nonatomic,assign) CGFloat brightValue;
@property (nonatomic,strong) NSMutableArray *lIDs;
@property (nonatomic,strong) NSMutableArray *lNames;
@property (nonatomic,strong) UIImageView *tranformView;

@property (weak, nonatomic) IBOutlet UIView *base;
@property (weak, nonatomic) IBOutlet UIButton *btnPen;
@property (nonatomic,strong) NSArray *lights;
@property (weak, nonatomic) IBOutlet UILabel *lightName;

@property (nonatomic,assign) int sceneID;
@property (nonatomic,assign) long lightCatalog;
@property (nonatomic,strong) YALContextMenuTableView* contextMenuTableView;
@property (nonatomic,strong) ORBSwitch *switcher;

- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender;

@end

@implementation LightController

- (IBAction)pickcolor:(id)sender {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 400.0)];
    view.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    
    STColorPicker *colorPicker = [[STColorPicker alloc] initWithFrame:CGRectMake(0.0, 40.0, 300.0, 350.0)];
    
    [colorPicker setColorHasChanged:^(UIColor *color, CGPoint location) {
        NSLog(@"%@",color);
        [self.base setBackgroundColor:color];
        [self save:self.base];
        [view dismiss];
    }];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setTitle:@"颜色面板" forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(5.0, 5.0, 80.0, 35.0);
    [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13.0];

    //[btn addTarget:self action:@selector(upInside) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:@"图片面板" forState:UIControlStateNormal];
    
    button.frame = CGRectMake(220.0, 5.0, 80.0, 35.0);
    [button setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    //[view addSubview:button];
    [view addSubview:colorPicker];
    [view show];
}

-(NSMutableArray *)lIDs
{
    if(!_lIDs)
    {
        _lIDs = [NSMutableArray array];
       
           if(self.sceneid > 0 && !self.isAddDevice)
           {
           
               NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
               for(int i = 0; i <lightArr.count; i++)
               {
                   NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[lightArr[i] intValue]];
                   if([typeName isEqualToString:@"灯光"])
                   {
                       [_lIDs addObject:lightArr[i]];
                   }
               }
           }else if(self.roomID > 0){
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:SWITCHLIGHT_SUB_TYPE andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:DIMMER_SUB_TYPE andRoomID:self.roomID]];
               [_lIDs addObjectsFromArray:[SQLManager getDeviceByTypeName:COLORLIGHT_SUB_TYPE andRoomID:self.roomID]];

           }else{
               [_lIDs addObject:self.deviceid?self.deviceid:@"0"];
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
            NSString *name = [SQLManager deviceNameByDeviceID:lID];
            [_lNames addObject:name];
        }
    }
    return _lNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 灯光",roomName]];
    [self initSwitch];

    self.scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        [self syncUI];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLight:) name:@"light" object:nil];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;

    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) syncUI
{
    for(id device in self.scene.devices)
    {
        if ([device isKindOfClass:[Light class]] && ((Light*)device).deviceID == [self.deviceid intValue]) {
            float brightness_f = (float)((Light *)device).brightness;
            int degree = brightness_f*MAX_ROTATE_DEGREE/100;
            self.tranformView.transform = CGAffineTransformMakeRotation(degree);
            //self.detailCell.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)(self.detailCell.bright.value * 100)];
            self.switcher.isOn=((Light*)device).isPoweron;
            if ([((Light*)device).color count]>2) {
                self.base.backgroundColor=[UIColor colorWithRed:[[((Light*)device).color firstObject] intValue]/255.0 green:[[((Light*)device).color objectAtIndex:1] intValue]/255.0  blue:[[((Light*)device).color lastObject] intValue]/255.0  alpha:1];
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
        self.switcher.isOn = (bool)state;
    }
    if (state == 0x0a) {
        //self.detailCell.bright.value=[dic[@"r"] intValue];
        float brightness_f = [dic[@"r"] intValue];
        int degree = brightness_f*MAX_ROTATE_DEGREE/100;
        self.tranformView.transform = CGAffineTransformMakeRotation(degree);
    }
    if (state == 0x0b) {
        self.base.backgroundColor=[UIColor colorWithRed:[dic[@"r"] intValue]/255.0 green:[dic[@"g"] intValue]/255.0  blue:[dic[@"b"] intValue]/255.0  alpha:1];
    }
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
    NSString *etype = [SQLManager getEType:[self.deviceid intValue]];
    
    if ([sender isEqual:self.switcher]) {
        NSData *data=[[DeviceInfo defaultManager] toogleLight:self.switcher.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    if (![etype isEqualToString:@"01"] && [sender isEqual:self.tranformView]) {
        //self.detailCell.power.on = self.detailCell.bright.value >0;
        
        NSData *data=[[DeviceInfo defaultManager] changeBright:self.tranformView.tag deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }
    
    if ([etype isEqualToString:@"03"] && [sender isEqual:self.base]) {
        UIColor *color = self.base.backgroundColor;
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
    [device setIsPoweron: self.switcher.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.base.backgroundColor];
    if (colors) {
        if ([etype isEqualToString:@"03"]) {
            [device setColor:colors];  
        }
        [device setColor:@[]];
    }
    
    if (![etype isEqualToString:@"01"])
    {
        [device setBrightness:(int)self.tranformView.tag];
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
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01 && proto.action.state == 0x7D){
        self.switcher.isOn = proto.action.RValue;
    }
    if (tag == 0 && (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON || proto.action.state == 0x0b || proto.action.state == 0x0a)) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
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
    if ([RGBArr count]>3) {
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
    }
    //返回保存RGB值的数组
    return RGBStrValueArr;
}

- (void)setSelectedColor:(UIColor *)color
{
    self.base.backgroundColor = color;
    [self save:nil];
}


- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender {
    
    //self.detailCell.label.text = self.lNames[sender.selectedSegmentIndex];
    //self.deviceid = [self.lIDs objectAtIndex:self.segmentLight.selectedSegmentIndex];
    [self syncUI];
    //[self.tableView reloadData];
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

#pragma mark -

//明快
- (IBAction)SprightlierBtn:(id)sender {
    
    [[SceneManager defaultManager] sprightly:[self.sceneid intValue]];
}
//幽静
- (IBAction)PeacefulBtn:(id)sender {
    
    [[SceneManager defaultManager] gloom:[self.sceneid intValue]];
}
//浪漫
- (IBAction)RomanceBtn:(id)sender {
    
    [[SceneManager defaultManager] romantic:[self.sceneid intValue]];
}
- (IBAction)LightSlider:(id)sender {
    
    [[SceneManager defaultManager] dimingScene:[self.sceneid intValue] brightness:[self.deviceid intValue]];
    //[self.lightSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"light" object:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    CGFloat radius = atan2f(self.tranformView.transform.b, self.tranformView.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    
    /**
     CGRectGetHeight 返回控件本身的高度
     CGRectGetMinY 返回控件顶部的坐标
     CGRectGetMaxY 返回控件底部的坐标
     CGRectGetMinX 返回控件左边的坐标
     CGRectGetMaxX 返回控件右边的坐标
     CGRectGetMidX 表示得到一个frame中心点的X坐标
     CGRectGetMidY 表示得到一个frame中心点的Y坐标
     */
    
    CGPoint center = CGPointMake(CGRectGetMidX([touch.view bounds]), CGRectGetMidY([touch.view bounds]));
    CGPoint currentPoint = [touch locationInView:touch.view];//当前手指的坐标
    CGPoint previousPoint = [touch previousLocationInView:touch.view];//上一个坐标
    
    /**
     求得每次手指移动变化的角度
     atan2f 是求反正切函数 参考:http://blog.csdn.net/chinabinlang/article/details/6802686
     */
    CGFloat angle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x) - atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    
    if (degree<0) {
        if (angle<0) {
            return;
        }
    }else if (degree>MAX_ROTATE_DEGREE) {
        if (angle>0) {
            return;
        }
    }
    self.tranformView.transform = CGAffineTransformRotate(self.tranformView.transform, angle);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat radius = atan2f(self.tranformView.transform.b, self.tranformView.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    NSLog(@"degree:%f",degree);
    int percent = degree*100/MAX_ROTATE_DEGREE;
    NSLog(@"percent:%d",percent);
    self.tranformView.tag = percent;
    [self save:self.tranformView];
}

-(void) initSwitch
{
    self.base.layer.cornerRadius = 120;
    self.tranformView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
    self.tranformView.center = CGPointMake(self.view.bounds.size.width / 2,
                                  self.view.bounds.size.height / 2);
    self.tranformView.image = [UIImage imageNamed:@"glory"];
    self.tranformView.hidden = YES;
    
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"lighting_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 194, 194)];
    self.switcher.center = CGPointMake(self.view.bounds.size.width / 2,
                                  self.view.bounds.size.height / 2);
    //self.switcher.layer.cornerRadius = 194/2;
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;
    [self.view addSubview:self.switcher];

    [self.view addSubview:self.tranformView];
}

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    [self save:self.switcher];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"lighting_on" : @"lighting_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];

}

- (IBAction)loadCatalog:(id)sender {
    self.lightCatalog = ((UIButton *)sender).tag;
    self.btnPen.hidden=(self.lightCatalog == 3?NO:YES);
    self.tranformView.hidden=(self.lightCatalog == 2?NO:YES);
    NSString *catalogID = [NSString stringWithFormat:@"0%ld",((UIButton *)sender).tag];
    [self initiateMenuOptions:catalogID];
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.15;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Left;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    if ([self.lights count]>0) {
        [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(80+22,0,0,0) animated:YES];
    }
}

#pragma mark - Local methods
- (void)initiateMenuOptions:(NSString *)catalogID {
    self.lights = [SQLManager devicesWithCatalogID:catalogID room:self.roomID];
    [self.contextMenuTableView reloadData];
}

#pragma mark - YALContextMenuTableViewDelegate
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.lightName.text = [[self.lights objectAtIndex:indexPath.row] objectForKey:@"name"];
    self.deviceid = [[self.lights objectAtIndex:indexPath.row] objectForKey:@"id"];
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lights.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [[self.lights objectAtIndex:indexPath.row] objectForKey:@"name"];
        [cell setContraint:self.lightCatalog];
    }
    
    return cell;
}

@end
