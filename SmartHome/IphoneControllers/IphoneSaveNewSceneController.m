//
//  IphoneFavorSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneSaveNewSceneController.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "IphoneNewAddSceneTimerVC.h"
#import "SQLManager.h"
#import "PhotoGraphViewConteoller.h"

@interface IphoneSaveNewSceneController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,PhotoGraphViewConteollerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sceneName;//输入场景名的输入框
@property (weak, nonatomic) IBOutlet UIButton *sceneImageBtn;//选择场景图片的button
@property (nonatomic,strong) UIImage *selectSceneImg;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *PushBtn;//定时跳转按钮
@property (weak, nonatomic) IBOutlet UILabel *SceneTimingLabel;//显示场景的定时的具体时间段
@property (weak, nonatomic) IBOutlet UIButton *startSceneBtn;//是否立即启用场景

@end

@implementation IphoneSaveNewSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.sceneName setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
       [self reachNotification];
    [self setupNaviBar];
}
- (void)setupNaviBar {
    [self setNaviBarTitle:@"保存场景"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
    //    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFixTimeInfo:) name:@"AddSceneOrDeviceTimerNotification" object:nil];
}
-(void)getFixTimeInfo:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
 
    self.SceneTimingLabel.text = [NSString stringWithFormat:@"%@-%@,%@",dic[@"startDay"],dic[@"endDay"],dic[@"repeat"]];
}
-(void)rightBtnClicked:(UIButton *)bbi
{
    if ([self.sceneName.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"场景名不能为空!"];
        return;
    }
    
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    Scene *scene = [[Scene alloc]initWhithoutSchedule];
    scene.roomID = self.roomId;
    [scene setValuesForKeysWithDictionary:plistDic];
//    [[DeviceInfo defaultManager] setEditingScene:NO];
    
    [[SceneManager defaultManager] addScene:scene withName:self.sceneName.text withImage:self.selectSceneImg];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sceneImageBtn:(id)sender {
    UIAlertController * alerController = [UIAlertController alertControllerWithTitle:@"温馨提示选择场景图片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"现在就拍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }]];
   
    [alerController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DeviceInfo defaultManager].isPhotoLibrary = YES;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            return;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker shouldAutorotate];
        [picker supportedInterfaceOrientations];
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"从预设图片选" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIStoryboard *MainStoryBoard  = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        PhotoGraphViewConteoller *tvIconVC = [MainStoryBoard instantiateViewControllerWithIdentifier:@"PhotoGraphViewConteoller"];
        [self.navigationController pushViewController:tvIconVC animated:YES];
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alerController animated:YES completion:^{
        
    }];

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    self.selectSceneImg = info[UIImagePickerControllerEditedImage];
    [self.sceneImageBtn setBackgroundImage:self.selectSceneImg forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)PhotoIconController:(PhotoGraphViewConteoller *)iconVC withImgName:(NSString *)imgName
{
    self.chooseImgeName = imgName;
    [self.sceneImageBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}
- (IBAction)clickCancle:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//跳转到定时界面
- (IBAction)PushBtn:(id)sender {
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    IphoneNewAddSceneTimerVC * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
    iphoneSaveNewScene.naviTitle = @"场景定时";
    // [self presentViewController:iphoneSaveNewScene animated:YES completion:nil];
    [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
    
}
- (IBAction)startSceneBtn:(id)sender {
    
    self.startSceneBtn.selected = !self.startSceneBtn.selected;
    if (self.startSceneBtn.selected) {
        [self.startSceneBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
        [SQLManager updateSceneStatus:0 sceneID:self.sceneID];//更新数据库
    }else{
        [self.startSceneBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] startScene:self.sceneID];
        [SQLManager updateSceneStatus:1 sceneID:self.sceneID];//更新数据库
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
