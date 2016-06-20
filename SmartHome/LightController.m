//
//  Light.m
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LightController.h"
#import "DetailViewController.h"


@interface LightController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favButt;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) CGFloat brightValue;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentLight;
- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender;

@end

@implementation LightController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.detailCell = [[[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil] lastObject];
    self.detailCell.bright.continuous = NO;
    [self.detailCell.bright addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    

     [self.detailCell.power addTarget:self action:@selector(save:)forControlEvents:UIControlEventValueChanged];
    
     self.cell = [[[NSBundle mainBundle] loadNibNamed:@"ColourTableViewCell" owner:self options:nil] lastObject];

    

    
    if ([self.sceneid intValue]>0) {
        _favButt.enabled=YES;
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(id device in scene.devices)
        {
            if ([device isKindOfClass:[Light class]]) {
                self.detailCell.bright.value=((Light*)device).brightness/100.0;
                self.detailCell.power.on=((Light*)device).isPoweron;
                self.cell.colourView.backgroundColor=[UIColor colorWithRed:[[((Light*)device).color firstObject] intValue]/255.0 green:[[((Light*)device).color objectAtIndex:1] intValue]/255.0  blue:[[((Light*)device).color lastObject] intValue]/255.0  alpha:1];
            }
        }
    }
    
    
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
     self.title = @"灯";
}

-(IBAction)save:(id)sender
{
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron: self.detailCell.power.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.cell.colourView.backgroundColor];
    [device setColor:colors];
    [device setBrightness:self.detailCell.bright.value*100];
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:2];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device id:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:@"" withPic:@""];
}

-(IBAction)favorite:(id)sender
{
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron: self.detailCell.power.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.cell.colourView.backgroundColor];
    [device setColor:colors];
    [device setBrightness:self.detailCell.bright.value*100];
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    NSMutableArray *array=[NSMutableArray arrayWithObject:device];
    [scene setDevices:array];
    [[SceneManager defaultManager] favoriteScenen:scene withName:@"睡觉模式"];
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
    return 3;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        
        self.detailCell.label.text = @"射灯";
        self.detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.detailCell;
    } else if(indexPath.row == 1)
    {
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
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}

- (IBAction)selectTypeOfLight:(UISegmentedControl *)sender {
    
    if(0 == sender.selectedSegmentIndex)
    {
        self.detailCell.label.text = @"射灯";
    }else  if (1 == sender.selectedSegmentIndex){
        self.detailCell.label.text = @"廊灯";
    }else
        self.detailCell.label.text  = @"吊灯";
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
