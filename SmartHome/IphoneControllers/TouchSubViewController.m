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


@class IphoneEditSceneController;
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
    
    IphoneEditSceneController * editScene;
    self.delegate = editScene;
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
       
        [self.delegate removeSecene];
        
    }else if (indexPath.row == 1){
     
        [self.delegate collectSecene];
    }

}
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
    }];
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
       
        [self.delegate colseSecene];
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
