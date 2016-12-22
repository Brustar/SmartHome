//
//  TouchSubViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TouchSubViewController.h"
#import "SceneManager.h"
#import "Scene.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+WebCache.h"

@interface TouchSubViewController ()

@property (nonatomic,strong)NSArray * arrayData;
@property (nonatomic,strong) NSArray * IconImageArr;
@property (weak, nonatomic) IBOutlet UIImageView *PicImageView;

@end

@implementation TouchSubViewController

//- (instancetype)initWithTitle:(NSString *)title
//{
//    self = [super init];
//    if (self) {
//        title =self.sceneName.text;
//        self.title =title;
//    }
//    return self;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    
    self.title = [SQLManager getSceneName:self.sceneID];
//     _sceneName.text = [SQLManager getSceneName:self.sceneID];
    
    NSString * UrlStr = [SQLManager getDevicePicByID:self.sceneID];
     [self.PicImageView sd_setImageWithURL:[NSURL URLWithString:UrlStr] placeholderImage:[UIImage imageNamed:@"PL"]];
}
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        [[SceneManager defaultManager] startScene:self.sceneID];
    }];
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
       
          [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
       
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"收藏此场景" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
        if (scene) {
            BOOL result = [[SceneManager defaultManager] favoriteScene:scene];
            if (result) {
                [MBProgressHUD showSuccess:@"已收藏"];
            }else {
                [MBProgressHUD showError:@"收藏失败"];
            }
        }
       
    }];
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"删除此场景" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //删除数据库记录
        BOOL delSuccess = [SQLManager deleteScene:self.sceneID];
        if (delSuccess) {
            //删除场景文件
            Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
            if (scene) {
                [[SceneManager defaultManager] delScene:scene];
                [MBProgressHUD showSuccess:@"删除成功"];
            }else {
                NSLog(@"scene 不存在！");
                [MBProgressHUD showSuccess:@"删除失败"];
            }
        }
        
    }];
    
    return @[action,action1,action2,action3];
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
