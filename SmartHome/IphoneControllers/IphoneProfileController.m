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
#import "MSGController.h"

#define hight 50
@class MsgCell;
@interface IphoneProfileController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *PorTraintButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) NSArray *titlArr;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHight;
@property (nonatomic,strong) NSArray *images;
@property (nonatomic,strong) NSArray *segues;
//@property (nonatomic,strong) MsgCell * MsgCell;
@property (nonatomic,strong) NSMutableArray * unreadcountArr;
@property (nonatomic,assign) BOOL * isShowUnread;
@end

@implementation IphoneProfileController
-(NSMutableArray *)unreadcountArr
{
    if (!_unreadcountArr) {
        _unreadcountArr = [NSMutableArray array];
    }
    
    return _unreadcountArr;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.unreadcountArr removeAllObjects];
    [self creatItemID];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"UserName"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    self.titlArr = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息"];
    self.images = @[@"my",@"energy",@"record",@"store",@"message"];
//    self.tableHight.constant = self.titlArr.count * hight + self.headView.frame.size.height;
    self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView = self.headView;
    DeviceInfo *device = [DeviceInfo defaultManager];
    if (![device.db isEqualToString:SMART_DB]){
        
        self.segues =@[@"iphoneDefault",@"iphoneRecordSegue",@"TYiphone",@"iphoneFavorSegue",@"iphoneMsgSegue"];
    }else{
        self.segues = @[@"iphoneDefault",@"iphoneRecordSegue",@"iphoneEngerSegue",@"iphoneFavorSegue",@"iphoneMsgSegue"];
    }
    
 
}

-(void)creatItemID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:2]};
        HttpManager *http=[HttpManager defaultManager];
        http.tag = 2;
        http.delegate = self;
        [http sendPost:url param:dict];
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
//        self.imageView.hidden = YES;
        [cell.imageView addSubview:self.imageView];
        
    }
     NSMutableArray * subArr = [NSMutableArray array];
    for (int i = 0; i < self.unreadcountArr.count; i ++) {
        if ([self.unreadcountArr[i] intValue] == 0) {
            [subArr addObject:self.unreadcountArr[i]];
        }
        if (self.unreadcountArr.count == subArr.count) {
            self.imageView.hidden = YES;
        }
        else{
            self.imageView.hidden = NO;
        }
        
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
    if (tag == 2) {
        if ([responseObject[@"result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"notify_type_list"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
    
                    [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
                }
            }
         
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:self.segues[indexPath.row] sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
