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
#import "PackManager.h"
#import "SQLManager.h"
#import "UIImageView+Badge.h"
#import "ORBSwitch.h"

#define MAX_TEMP_ROTATE_DEGREE 285
#define MIX_TEMP_ROTATE_DEGREE 75

@interface AirController ()<RulerViewDatasource, RulerViewDelegate,UITableViewDataSource,UITableViewDelegate,ORBSwitchDelegate>
@property (weak, nonatomic) IBOutlet RulerView *thermometerView;
@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;
@property (weak, nonatomic) IBOutlet UILabel *wetLabel;
@property (weak, nonatomic) IBOutlet UILabel *pmLabel;
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;
@property (weak, nonatomic) IBOutlet UITableView *paramView;
@property (weak, nonatomic) IBOutlet UIImageView *pm_clock_hand;
@property (weak, nonatomic) IBOutlet UIImageView *humidity_hand;
@property (weak, nonatomic) IBOutlet UIButton *disk;
@property (weak, nonatomic) IBOutlet UILabel *tempretureLbl;

@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) IBOutlet UIImageView *tempreturePan;
@property (nonatomic,strong) ORBSwitch *switcher;


@end

@implementation AirController

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager singleDeviceWithCatalogID:air byRoom:self.roomID];;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"空调"];
    [self.pm_clock_hand rotate:90];
    [self.humidity_hand rotate:45];
    self.disk.enabled = NO;
    [self initSwitch];
    
    
    self.params=@[@[@"制热",@"制冷",@"抽湿",@"自动"],@[@"向上",@"向下"],@[@"高风",@"中风",@"低风"],@[@"0.5H",@"1H",@"2H",@"3H"]];
    self.paramView.scrollEnabled=NO;
    
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
}

-(void) initSwitch
{
    self.switcher = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"air_control_off"] inactiveBackgroundImage:nil activeBackgroundImage:nil frame:CGRectMake(0, 0, 122, 122)];
    
    self.switcher.knobRelativeHeight = 1.0f;
    self.switcher.delegate = self;

    [self.container addSubview:self.switcher];
    /*
    [self.switcher setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switcher
                                                attribute:NSLayoutAttributeCenterX
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:self.tempreturePan
                                                attribute:NSLayoutAttributeCenterX
                                                multiplier:1.0
                                                constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switcher
                                                attribute:NSLayoutAttributeCenterY
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:self.tempreturePan
                                                attribute:NSLayoutAttributeCenterY
                                                multiplier:1.0
                                                constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switcher
                                                attribute:NSLayoutAttributeWidth
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.0f constant:122.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.switcher
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.0f constant:122.0f]];

    */
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
    uint8_t cmd=0;
    if (self.currentButton == mode) {
        self.currentMode = self.currentIndex+1;
        if (self.currentIndex==0) {
            cmd = 0x39+self.currentIndex;
        }else{
            cmd = 0x3F+self.currentIndex;
        }
    }
    if (self.currentButton == level) {
        self.currentLevel = self.currentIndex+1;
        cmd = 0x35+self.currentIndex;
    }
    if (self.currentButton == direction) {
        self.currentDirection = self.currentIndex+1;
        cmd = 0x43+self.currentIndex;
    }
    if (self.currentButton == timing) {
        self.currentTiming = self.currentIndex+1;
    }
    NSData *data=[self createCmd:cmd];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [self save:nil];
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

#pragma mark - RulerViewDelegate
- (void)rulerView:(RulerView *)rulerView didChangedCurrentValue:(CGFloat)currentValue {
    NSInteger value = round(currentValue);
    
    NSString *valueString = [NSString stringWithFormat:@"%d ℃", (int)value];
    
    self.showTemLabel.text = valueString;
    
    NSData *data=[[DeviceInfo defaultManager] changeTemperature:0x6A deviceID:self.deviceid value:value];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [self save:nil];
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

#pragma mark - ORBSwitchDelegate
- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue {
    NSLog(@"Switch toggled: new state is %@", (newValue) ? @"ON" : @"OFF");
    [self save:self.switcher];
}

- (void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj {
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"air_control_cool" : @"air_control_off"]
          inactiveBackgroundImage:nil
            activeBackgroundImage:nil];
    
}

#pragma mark - UITouchDelegate
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    NSUInteger toucheNum = [[event allTouches] count];//有几个手指触摸屏幕
    if ( toucheNum > 1 ) {
        return;//多个手指不执行旋转
    }
    
    CGFloat radius = atan2f(self.tempreturePan.transform.b, self.tempreturePan.transform.a);
    CGFloat degree = radius * (180 / M_PI)+180;
    
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
    NSLog(@"degree:%f",degree)
    if (degree<75) {
        if (angle<0) {
            return;
        }
    }else if (degree>MAX_TEMP_ROTATE_DEGREE) {
        if (angle>0) {
            return;
        }
    }
    self.tempreturePan.transform = CGAffineTransformRotate(self.tempreturePan.transform, angle);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat radius = atan2f(self.tempreturePan.transform.b, self.tempreturePan.transform.a);
    CGFloat degree = radius * (180 / M_PI);
    NSLog(@"degree:%f",degree);
    int percent = degree*100/MAX_TEMP_ROTATE_DEGREE;
    NSLog(@"percent:%d",percent);
    self.tempreturePan.tag = percent;
    [self save:self.tempreturePan];
}

@end
