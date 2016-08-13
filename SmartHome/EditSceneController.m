//
//  EditSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/3.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

#import "EditSceneController.h"
#import "EditSceneCell.h"
#import "LightController.h"
#import "CurtainController.h"
#import "TVController.h"
#import "DeviceManager.h"
#import "Device.h"
#import "SceneManager.h"
@interface EditSceneController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *subDeviceTableView;

@property (weak, nonatomic) IBOutlet UIView *footerView;
//设备种类
@property(nonatomic,strong) NSArray *devicesTypes;

@property (weak, nonatomic) IBOutlet UIButton *realObjBtn;
@property (weak, nonatomic) IBOutlet UIButton *graphicBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *addDeviceBtn;
@property (nonatomic,strong) NSArray *subTypeArr;

@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (nonatomic,strong) LightController *ligthVC;
@property (nonatomic,strong) NSArray *controllersVC;
@property (nonatomic,strong) NSArray *devices;
@end

@implementation EditSceneController

-(NSArray *)controllersVC
{
    if(!_controllersVC)
    {
        UIStoryboard *sy = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LightController *ligthVC = [sy instantiateViewControllerWithIdentifier:@"LightController"];
        CurtainController *curtainVC = [sy instantiateViewControllerWithIdentifier:@"CurtainController"];
        TVController *tv = [sy instantiateViewControllerWithIdentifier:@"TVController"];
        _controllersVC = @[ligthVC,curtainVC,tv];
    }
    
    return _controllersVC;
}
-(NSArray *)devices
{
    if(!_devices)
    {
        //根据场景ID得到所有的设备类
        _devices = [SceneManager devicesBySceneID:self.sceneID];
        for(Device *device in _devices)

        {
            
        }
    }
    return _devices;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.subTypeArr = @[@"照明",@"影音"];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.backgroundColor = backGroudColour;
    self.subDeviceTableView.backgroundColor = backGroudColour;
    self.view.backgroundColor = backGroudColour;
    }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //右边的根据左边选中的设备大类的设备子类数量
    
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditSceneCell" forIndexPath:indexPath];
    if(tableView == self.tableView)
    {
        cell.label.text = self.devicesTypes[indexPath.row];
        [cell.button setBackgroundImage:[UIImage imageNamed:@"store"] forState:UIControlStateNormal];
    }else {
        //根据设备子类数据
        cell.label.text = self.devicesTypes[indexPath.row];
        [cell.button setBackgroundImage:[UIImage imageNamed:@"store"] forState:UIControlStateNormal];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < 3)
    {
        UIViewController *vc = self.controllersVC[indexPath.row];
        vc.view.frame = self.devicelView.frame;
        [self.view addSubview:vc.view];
        [self addChildViewController:vc];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.backgroundColor = backGroudColour;
    
    //cell.textLabel.textColor = [UIColor colorWithRed:152/255.0 green:172/255.0 blue:195/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
