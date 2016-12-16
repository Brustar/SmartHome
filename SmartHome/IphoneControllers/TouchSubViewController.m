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

@interface TouchSubViewController ()

@property (nonatomic,strong)NSArray * arrayData;
@property (nonatomic,strong) NSArray * IconImageArr;

@end

@implementation TouchSubViewController

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title =title;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.

}

-(void)setSceneName:(UILabel *)sceneName
{
    
    _sceneName = sceneName;

}
-(void)setSceneDescribe:(UILabel *)sceneDescribe
{
    _sceneDescribe = sceneDescribe;

}
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
    }];
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
       
        if ([self.delegate respondsToSelector:@selector(colseSecene)]) {
             [self.delegate colseSecene];
        }
       
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"收藏此场景" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        if ([self.delegate respondsToSelector:@selector(collectSecene)]) {
             [self.delegate collectSecene];
        }
       
    }];
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"删除此场景" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
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
