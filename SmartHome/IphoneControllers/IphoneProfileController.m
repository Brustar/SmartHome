//
//  IphoneProfireController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneProfileController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SocketManager.h"
#import "MsgCell.h"

#define hight 50
@interface IphoneProfileController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *PorTraintButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) NSArray *titlArr;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHight;
@property (nonatomic,strong) NSArray *images;
@property (nonatomic,strong) NSArray *segues;
@property (nonatomic,strong) UIImageView * imageView;
@end

@implementation IphoneProfileController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"UserName"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    self.titlArr = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息",@"设置"];
    self.images = @[@"my",@"energy",@"record",@"store",@"message",@"setting"];
//    self.tableHight.constant = self.titlArr.count * hight + self.headView.frame.size.height;
    self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView = self.headView;
    
    self.segues = @[@"iphoneDefault",@"iphoneRecordSegue",@"iphoneEngerSegue",@"iphoneFavorSegue",@"iphoneMsgSegue",@"iphoneSettingSegue"];
    
    MsgCell * cell = [[MsgCell alloc] init];

        if (cell.unreadcountImage.hidden == NO) {
            self.imageView.hidden = NO;
        }else{
            self.imageView.hidden = YES;
        }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.titlArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.titlArr[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.images[indexPath.row]];
    if ([cell.textLabel.text isEqualToString:@"我的消息"]) {
       self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(25, 0, 10, 10);
        self.imageView.backgroundColor = [UIColor redColor];
        self.imageView.layer.cornerRadius = self.imageView.bounds.size.width/2; //圆角半径
        self.imageView.layer.masksToBounds = YES; //圆角
        [cell.imageView addSubview:self.imageView];
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return hight;
}

- (IBAction)clickQuitButton:(id)sender {
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"退出后不会删除任何数据，下次依然可以使用本账号" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self clickQuitButton];
//        [self performSegueWithIdentifier:@"iphoneQuitSegue" sender:self];
    }];
    
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action1];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
-(void)clickQuitButton
{
    
    NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dict = @{@"token":authorToken};
        
        NSString *url = [NSString stringWithFormat:@"%@login/logout.aspx",[IOManager httpAddr]];
        HttpManager *http=[HttpManager defaultManager];
        http.delegate=self;
        http.tag = 1;
        [http sendPost:url param:dict];
        [self performSegueWithIdentifier:@"iphoneQuitSegue" sender:self];
    }else{
        //跳转到欢迎页
                [self performSegueWithIdentifier:@"iphoneQuitSegue" sender:self];
    }

}
- (IBAction)PorTraitButton:(id)sender {
    
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        
        PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        PickerImage.allowsEditing = YES;
        PickerImage.delegate = self;
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
 
   
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    _myHeadPortrait.image = newPhoto;
    [self.PorTraintButton setBackgroundImage:newPhoto forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AuthorToken"];
            [[SocketManager defaultManager] cutOffSocket];
            
            [self performSegueWithIdentifier:@"iphoneGoLogin" sender:self];
            
        }else {
            [MBProgressHUD showSuccess:responseObject[@"Msg"]];
        }
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:self.segues[indexPath.row] sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
