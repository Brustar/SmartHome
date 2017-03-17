//
//  ScreenCurtainController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScreenCurtainController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Amplifier.h"
#import "Scene.h"
#import "SceneManager.h"


@interface ScreenCurtainController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) NSMutableArray *screenCurtainNames;
@property (nonatomic,strong) NSMutableArray *screenCurtainIds;
@property (nonatomic,strong) DetailTableViewCell *cell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHightConstraint;

@end

@implementation ScreenCurtainController

-(NSMutableArray *)screenCurtainIds
{
    if(!_screenCurtainIds)
    {
        _screenCurtainIds = [NSMutableArray array];
        if(self.sceneid > 0 && !_isAddDevice )
        {
            NSArray *screenCurtain = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < screenCurtain.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[screenCurtain[i] intValue]];
                if([typeName isEqualToString:@"幕布"])
                {
                    [_screenCurtainIds addObject:screenCurtain[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_screenCurtainIds addObjectsFromArray:[SQLManager getDeviceByTypeName:@"幕布" andRoomID:self.roomID]];
        }else{
            [_screenCurtainIds addObject:self.deviceid];
        }
    }
    return _screenCurtainIds;
}
-(NSMutableArray *)screenCurtainNames
{
    if(!_screenCurtainNames)
    {
        _screenCurtainNames = [NSMutableArray array];
        for(int i = 0; i < self.screenCurtainIds.count; i++)
        {
            int screenCurtainID = [self.screenCurtainIds[i] intValue];
            [_screenCurtainNames addObject:[SQLManager deviceNameByDeviceID:screenCurtainID]];
        }
 
    }
    return _screenCurtainNames;
}

- (UIImage*)createImageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)setupButtons {
    
    CGFloat btnWidth = 60.0f;
    CGFloat btnHeight = 40.0f;
    CGFloat gap = (UI_SCREEN_WIDTH-btnWidth*3)/4;
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((i+1)*gap + i*btnWidth, btnHeight/2, btnWidth, btnHeight)];
        [btn setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[self createImageWithColor:[UIColor grayColor]] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 4.0;
        btn.layer.masksToBounds = YES;
        if (i == 0) {
            [btn setTitle:@"升起" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(upBtnAction:) forControlEvents:UIControlEventTouchUpInside];
           
        }else if (i == 1) {
            [btn setTitle:@"停止" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(stopBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }else if (i == 2) {
            [btn setTitle:@"降落" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(downBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        [self.view addSubview:btn];
    }
}

- (void)upBtnAction:(UIButton *)sender {
    NSData *data = [[DeviceInfo defaultManager] upScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)stopBtnAction:(UIButton *)sender {
    NSData *data = [[DeviceInfo defaultManager] stopScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)downBtnAction:(UIButton *)sender {
    NSData *data = [[DeviceInfo defaultManager] downScreenByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"幕布";
    [self setupButtons];
    self.tableHightConstraint.constant = 100;
    
    
    [self setupSeguentScreenCurtain];
}

-(void)setupSeguentScreenCurtain
{
    if(self.screenCurtainNames == nil || self.screenCurtainNames.count == 0)
    {
        return;
        
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.screenCurtainNames.count; i++)
    {
        [self.segment insertSegmentWithTitle:self.screenCurtainNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [self.screenCurtainIds objectAtIndex:self.segment.selectedSegmentIndex];
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
        cell.label.text = self.screenCurtainNames[self.segment.selectedSegmentIndex];
        self.switchView = cell.power;//[[UISwitch alloc] initWithFrame:CGRectZero];
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        if ([self.sceneid intValue]>0) {
            for(int i=0;i<[_scene.devices count];i++)
            {
                if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Amplifier class]]) {
                    cell.power.on=((Amplifier *)[_scene.devices objectAtIndex:i]).waiting;
                }
            }
        }
        [cell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
        self.cell = cell;
        return cell;
        
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"recell"];
            
        }
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 30)];
        [cell.contentView addSubview:label];
        label.text = @"详细信息";
        return cell;

    }
    
    
}
-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.cell.power]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.cell.power.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.cell.power.isOn];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
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
        [self performSegueWithIdentifier:@"screenCurtainDetailSegue" sender:self];
    }
}

- (IBAction)selectedScreenCurtain:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.cell.label.text = self.screenCurtainNames[segment.selectedSegmentIndex];
    self.deviceid=[self.screenCurtainIds objectAtIndex:self.segment.selectedSegmentIndex];
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
