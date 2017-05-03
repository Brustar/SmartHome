//
//  DeviceTimingViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/4/28.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceTimingViewController.h"
#import "IphoneNewAddSceneTimerVC.h"
#import "SceneManager.h"

@interface DeviceTimingViewController ()

@property (nonatomic,strong)UIButton * naviRightBtn;
@end

@implementation DeviceTimingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)DeviceTimingBtn:(id)sender {
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    IphoneNewAddSceneTimerVC * iphoneNewAddSceneVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
    [self.navigationController pushViewController:iphoneNewAddSceneVC animated:YES];
    [self setupNaviBar];
    
}
- (void)setupNaviBar {
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题

   _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
   
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)btn
{
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    Scene *scene = [[Scene alloc]initWhithoutSchedule];
    scene.roomID = self.roomId;
    [scene setValuesForKeysWithDictionary:plistDic];
    [[DeviceInfo defaultManager] setEditingScene:NO];
    
//    [[SceneManager defaultManager] addScene:scene withName:self.sceneName.text withImage:self.selectSceneImg];
    [self.navigationController popViewControllerAnimated:YES];
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
