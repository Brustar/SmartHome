//
//  TouchSubViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TouchSubViewController.h"

@interface TouchSubViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        
    }];
    return @[action];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayData = @[@"删除此场景",@"收藏",@"语音"];
    self.IconImageArr = @[@"delete",@"store",@"voice"];
    // Do any additional setup after loading the view.
    
    
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
