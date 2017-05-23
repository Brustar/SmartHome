//
//  PushSettingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PushSettingController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "PushSettingCell.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface PushSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *sectionTitles;
@property (weak, nonatomic) IBOutlet UIView *coverView;
//int _sectionStatus[26];//默认:关闭
@property (weak, nonatomic) IBOutlet UIView *pushTypeView;
@property (nonatomic,strong) UIButton *selectedBtn;
- (IBAction)selectPsuhTypeBtn:(UIButton *)sender;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) NSMutableArray *names;
@property (nonatomic,strong) NSMutableArray *typeNames;
@property (nonatomic,strong) NSMutableArray *notifyWay;
@property (nonatomic,strong) NSMutableArray *recordIDs;
@property (nonatomic,assign) NSInteger tag;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *typeBtns;
@property (nonatomic,strong) NSArray * array;


@end

@implementation PushSettingController
{
          int _sectionStatus[5];//默认:关闭
}
-(NSMutableArray *)names
{
    if(!_names)
    {
        _names = [NSMutableArray array];
    }
    return  _names;
}
-(NSMutableArray *)typeNames
{
    if(!_typeNames)
    {
        _typeNames = [NSMutableArray array];
    }
    return _typeNames;
}
-(NSMutableArray *)notifyWay
{
    if(!_notifyWay)
    {
        _notifyWay = [NSMutableArray array];
    }
    return _notifyWay;
}
-(NSMutableArray *)recordIDs{
    if(!_recordIDs)
    {
        _recordIDs = [NSMutableArray array];
    }
    return _recordIDs;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNaviBarTitle:@"推送设置"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    self.tableView.tableFooterView = [UIView new];
    [self sendRequest];
}
//获得所有设置请求
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInt:0]};
        HttpManager *http=[HttpManager defaultManager];
        http.tag = 1;
        http.delegate = self;
        [http sendPost:url param:dict];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue]==0){
            NSArray *messageInfo = responseObject[@"user_notify_list"];
            for(NSDictionary *item in messageInfo)
            {
                [self.names addObject:item[@"item_name"]];
                [self.notifyWay addObject:item[@"notifyway"]];
                [self.recordIDs addObject:item[@"usernotify_id"]];
            }
            [self.tableView reloadData];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }
 
    }else if(tag == 2)
    {
        if ([responseObject[@"result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"修改成功"];
           
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
//         [self.tableView reloadData];
    }
    
}
-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.names.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PushSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushSettingCell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor lightGrayColor];
    cell.SettingNameLabel.text = self.names[indexPath.row];
//    cell.TypeLabel.hidden = YES;
    
    cell.TypeLabel.font = [UIFont systemFontOfSize:13];
    cell.TypeLabel.textColor = [UIColor lightGrayColor];
    NSNumber *num = self.notifyWay[indexPath.row];
    if([num intValue] == 1)
    {
        cell.TypeLabel.text = @"信息推送";
    }else if([num intValue] == 2)
    {
        cell.TypeLabel.text = @"短信通知";
    }else {
        cell.TypeLabel.text = @"不通知";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    self.selectedBtn.selected = NO;
    //    [self.selectedBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    self.coverView.hidden = NO;
    self.pushTypeView.hidden = NO;
    
    //    NSArray *notiWay = self.notifyWay[indexPath.section];
    //    NSNumber *num = notiWay[indexPath.row];
    NSNumber * num = self.notifyWay[indexPath.row];
    
    if([num intValue] == 1)
    {
        self.selectedBtn = self.typeBtns[0];
    }else if([num intValue] == 2)
    {
        self.selectedBtn = self.typeBtns[1];
    }else {
        self.selectedBtn = self.typeBtns[2];
    }
    
    for (UIButton *button in self.typeBtns) {
        button.enabled = YES;
    }
    
    self.selectedBtn.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
- (IBAction)selectPsuhTypeBtn:(UIButton *)sender {
    
    self.selectedBtn.enabled = YES;
    sender.enabled = NO;
    self.selectedBtn = sender;
    self.tag = sender.tag;
}
//设置通知类型请求
-(void)setUserNotifyWay:(NSInteger)way andRecord:(NSNumber *)recoredID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
    NSDictionary *dict = @{@"token":auothorToken,@"notifyway":[NSNumber numberWithInteger:way],@"usernotify_id":recoredID,@"optype":[NSNumber numberWithInt:3]};
    HttpManager *http=[HttpManager defaultManager];
    http.tag = 2;
    http.delegate = self;
    [http sendPost:url param:dict];
        
    }
}

- (IBAction)clickSureBtn:(id)sender {
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    PushSettingCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];

    NSNumber *recordID = self.recordIDs[self.indexPath.row];
    if(self.tag == 0)
    {
        cell.TypeLabel.text = @"信息推送";
        [self setUserNotifyWay:1 andRecord:recordID];
        
    }else if(self.tag == 1){
        cell.TypeLabel.text = @"短信通知";
        [self setUserNotifyWay:2 andRecord:recordID];
    }else{
        cell.TypeLabel.text = @"不通知";
        [self setUserNotifyWay:3 andRecord:recordID];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;

}

@end
