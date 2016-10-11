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

#define hight 50
@interface IphoneProfileController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) NSArray *titlArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHight;
@property (nonatomic,strong) NSArray *images;
@property (nonatomic,strong) NSArray *segues;
@end

@implementation IphoneProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"UserName"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    self.titlArr = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息",@"设置"];
    self.images = @[@"my",@"energy",@"record",@"store",@"message",@"setting"];
    self.tableHight.constant = self.titlArr.count * hight + self.headView.frame.size.height;
    self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView = self.headView;
    
    self.segues = @[@"iphoneDefault",@"iphoneRecordSegue",@"iphoneEngerSegue",@"iphoneFavorSegue",@"iphoneMsgSegue",@"iphoneSettingSegue"];
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
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return hight;
}

- (IBAction)clickQuitButton:(id)sender {
    NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dict = @{@"AuthorToken":authorToken};
        
        NSString *url = [NSString stringWithFormat:@"%@UserLogOut.aspx",[IOManager httpAddr]];
        HttpManager *http=[HttpManager defaultManager];
        http.delegate=self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }else{
        //跳转到欢迎页
        
        [self performSegueWithIdentifier:@"iphoneQuitSegue" sender:self];
    }

}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
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
