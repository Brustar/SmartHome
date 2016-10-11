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


@interface IphoneSaveNewSceneController ()
@property (weak, nonatomic) IBOutlet UITextField *sceneName;

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
    
    [[SceneManager defaultManager] saveAsNewScene:scene withName:self.sceneName.text withPic:nil];
    [self.navigationController popViewControllerAnimated:YES];

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
