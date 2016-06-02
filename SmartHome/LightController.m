//
//  Light.m
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LightController.h"

@interface LightController ()

@end

@implementation LightController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"场景-灯";
    
    self.bright.continuous = NO;
    [self.bright addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
     [self.power addTarget:self action:@selector(save:)forControlEvents:UIControlEventValueChanged];
    
     UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeColor:)];
    self.color.userInteractionEnabled=YES;
    [self.color addGestureRecognizer:singleTap];
    self.bright.value=0;
    self.favorite.hidden=YES;
    self.remove.hidden=YES;

    if ([self.sceneid intValue]>0) {
        self.favorite.hidden=NO;
        self.remove.hidden=NO;
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(id device in scene.devices)
        {
            if ([device isKindOfClass:[Light class]]) {
                self.bright.value=((Light*)device).brightness/100.0;
                self.power.on=((Light*)device).isPoweron;
                self.color.backgroundColor=[UIColor colorWithRed:[[((Light*)device).color firstObject] intValue]/255.0 green:[[((Light*)device).color objectAtIndex:1] intValue]/255.0  blue:[[((Light*)device).color lastObject] intValue]/255.0  alpha:1];
            }
        }
    }
}

-(IBAction)save:(id)sender
{
    Light *device=[[Light alloc] init];
    [device setDeviceID:1];
    [device setIsPoweron:self.power.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.color.backgroundColor];
    [device setColor:colors];
    [device setBrightness:self.bright.value*100];
    
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
    [device setDeviceID:1];
    [device setIsPoweron:self.power.isOn];
    NSArray *colors=[self changeUIColorToRGB:self.color.backgroundColor];
    [device setColor:colors];
    [device setBrightness:self.bright.value*100];
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

-(IBAction)remove:(id)sender
{
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setReadonly:NO];
    [[SceneManager defaultManager] delScenen:scene];
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
    HRSampleColorPickerViewController *controller= [[HRSampleColorPickerViewController alloc] initWithColor:self.color.backgroundColor fullColor:NO];
    controller.delegate = self;
    [self.navigationController pushViewController:controller
                                         animated:YES];
}

- (void)setSelectedColor:(UIColor *)color
{
    self.color.backgroundColor = color;
    [self save:nil];
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
