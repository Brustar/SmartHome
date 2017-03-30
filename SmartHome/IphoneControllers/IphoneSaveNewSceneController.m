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
#import "KxMenu.h"

@interface IphoneSaveNewSceneController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sceneName;//输入场景名的输入框
@property (weak, nonatomic) IBOutlet UIButton *sceneImageBtn;//选择场景图片的button
@property (nonatomic,strong)UIImage *selectSceneImg;

@end

@implementation IphoneSaveNewSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)storeNewScene:(id)sender {
    
    if ([self.sceneName.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"场景名不能为空!"];
        return;
    }
    
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    Scene *scene = [[Scene alloc]initWhithoutSchedule];
    [scene setValuesForKeysWithDictionary:plistDic];
    
    [[SceneManager defaultManager] saveAsNewScene:scene withName:self.sceneName.text withPic:self.selectSceneImg];
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)sceneImageBtn:(id)sender {
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat w = view.frame.size.width;
    CGFloat h = view.frame.size.height;
    CGFloat y = btn.frame.origin.y + btn.frame.size.height / 2 - 10;
    CGFloat x = btn.center.x - w / 2 - 30;
    [KxMenu showMenuInView:view fromRect:CGRectMake(x, y , w, h) menuItems:@[
                                                                             [KxMenuItem menuItem:@"本地图库"
                                                                                            image:nil
                                                                                           target:self
                                                                                           action:@selector(selectPhoto:)],
                                                                             [KxMenuItem menuItem:@"现在拍摄"
                                                                                            image:nil
                                                                                           target:self
                                                                                           action:@selector(takePhoto:)],
                                                                             ]];
}
- (void)selectPhoto:(KxMenuItem *)item {
    [DeviceInfo defaultManager].isPhotoLibrary = YES;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker shouldAutorotate];
    [picker supportedInterfaceOrientations];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
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
- (IBAction)clickCancle:(id)sender {
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
