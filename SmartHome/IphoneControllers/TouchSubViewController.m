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

@interface TouchSubViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSArray * arrayData;
@property (weak, nonatomic) IBOutlet UIView *sceneView;
@property (weak, nonatomic) IBOutlet UILabel *sceneName;
@property (weak, nonatomic) IBOutlet UILabel *sceneDescribe;
@property (nonatomic,strong) NSArray * IconImageArr;
@property (nonatomic,strong)  IphoneAddSceneController * addSceneVC;
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
    self.arrayData = @[@"删除此场景",@"收藏"];
    self.IconImageArr = @[@"delete",@"store"];
    // Do any additional setup after loading the view.
    NSLog(@"%i", self.tableView.delegate == self);
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    
    cell.imageView.image = [UIImage imageNamed:self.IconImageArr[indexPath.row]];

    cell.textLabel.text = self.arrayData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
//        self.cell = cell;
//        cell.deleteBtn.hidden = YES;
//        
//        [SQLManager deleteScene:(int)cell.tag];
//        Scene *scene = [[SceneManager defaultManager] readSceneByID:(int)cell.tag];
//        [[SceneManager defaultManager] delScene:scene];
//        
//        NSString *url = [NSString stringWithFormat:@"%@SceneDelete.aspx",[IOManager httpAddr]];
//        NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"SID":[NSNumber numberWithInt:scene.sceneID]};
//        HttpManager *http=[HttpManager defaultManager];
//        http.delegate=self;
//        http.tag = 1;
//        [http sendPost:url param:dict];
    }else if (indexPath.row == 1){
        //判断先前我们设置的唯一标识
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"收藏场景" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:  UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            IphoneAddSceneController * addSceneVC ;
            Scene *scene = [[SceneManager defaultManager] readSceneByID:addSceneVC.sceneID];
            
            [[SceneManager defaultManager] favoriteScene:scene withName:scene.sceneName];
            
            
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action1];
        [alert addAction:action2];
        
        [self presentViewController:alert animated:YES completion:nil];
    }

}
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
    }];
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        IphoneAddSceneController * addSceneVC;
        [[SceneManager defaultManager] poweroffAllDevice:addSceneVC.sceneID];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    return @[action,action1];
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
