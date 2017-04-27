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
    self.title = @"推送控制";
    self.automaticallyAdjustsScrollViewInsets = NO;
//    UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
//    self.navigationItem.leftBarButtonItem = returnItem;
    _array = @[@"信息推送",@"短信通知",@"不通知"];
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    self.tableView.tableFooterView = [UIView new];
    
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        [self sendRequest];
    }else {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"userPushNotifyList" ofType:@"plist"]];
        NSArray *arr = plistDict[@"user_notify_list"];
        if ([arr isKindOfClass:[NSArray class]]) {
            for(NSDictionary *item in arr)
            {
                [self.names addObject:item[@"item_name"]];
                [self.notifyWay addObject:item[@"notifyway"]];
                [self.recordIDs addObject:item[@"usernotify_id"]];
            }
        }
        [self.tableView reloadData];
    }
    
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.names.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * str = self.names[section];
    
    return str;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sectionStatus[section]) { //1表示展开 0表示收起
        //表示展开
        return [_array count];
    }else{
        return 0;//0行
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PushSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushSettingCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    cell.SettingNameLabel.text = _array[indexPath.row];
    cell.TypeLabel.hidden = YES;
    
//    cell.TypeLabel.font = [UIFont systemFontOfSize:13];
//    cell.TypeLabel.textColor = [UIColor lightGrayColor];
//    NSNumber *num = self.notifyWay[indexPath.row];
//    if([num intValue] == 1)
//    {
//        cell.TypeLabel.text = @"信息推送";
//    }else if([num intValue] == 2)
//    {
//        cell.TypeLabel.text = @"短信通知";
//    }else {
//        cell.TypeLabel.text = @"不通知";
//    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    self.selectedBtn.selected = NO;
//    [self.selectedBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    PushSettingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        //        [self sendNotification:indexPath.row select:1];
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        //        [self sendNotification:indexPath.row select:0];
    }
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
    DeviceInfo *device = [DeviceInfo defaultManager];
    
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
//    NSArray *item = self.recordIDs[self.indexPath.section];
    NSNumber *recordID = self.recordIDs[self.indexPath.row];
    if(self.tag == 0)
    {
        cell.detailTextLabel.text = @"信息推送";
        if ([device.db isEqualToString:SMART_DB]) {
            [self setUserNotifyWay:1 andRecord:recordID];
        }else {
            [MBProgressHUD showSuccess:@"修改成功"];
        }
        
    }else if(self.tag == 1)
    {
        cell.detailTextLabel.text = @"短信通知";
        if ([device.db isEqualToString:SMART_DB]) {
            [self setUserNotifyWay:2 andRecord:recordID];
        }else {
            [MBProgressHUD showSuccess:@"修改成功"];
        }
    }else{
        cell.detailTextLabel.text = @"不通知";
        if ([device.db isEqualToString:SMART_DB]) {
            [self setUserNotifyWay:3 andRecord:recordID];
        }else {
            [MBProgressHUD showSuccess:@"修改成功"];
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;

}
#pragma mark 分区的头视图
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.tableView != tableView) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kScreenSize.width-40, 0, 30, 30);
    button.tag = 101+section;
    //    button.backgroundColor = [UIColor yellowColor];
    if (_sectionStatus[section] != 0) {
        [button setImage:[UIImage imageNamed:@"icon_dd_normal"] forState:UIControlStateNormal];
    }else{
        [button setImage:[UIImage imageNamed:@"icon_dd_normal"] forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    //推送的名字
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    [nameLabel setText:self.names[section]];
     [view addSubview:nameLabel];
    
    //通知的方式
    UILabel * tyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width-160, 0, 100, 40)];
    tyLabel.textAlignment = NSTextAlignmentRight;
    tyLabel.textColor = [UIColor lightGrayColor];
    tyLabel.backgroundColor = [UIColor clearColor];
    tyLabel.font = [UIFont systemFontOfSize:13];
    NSNumber *num = self.notifyWay[section];
    if([num intValue] == 1)
    {
        tyLabel.text = @"信息推送";
    }else if([num intValue] == 2)
    {
        tyLabel.text = @"短信通知";
    }else {
        tyLabel.text = @"不通知";
    }
    [view addSubview:tyLabel];
    //上显示线
    
    UILabel *label1=[[ UILabel alloc ] initWithFrame : CGRectMake ( 0 , - 1 , view. frame . size . width , 1 )];
    
    label1. backgroundColor =[ UIColor whiteColor];
    
    [view addSubview :label1];
    
    //下显示线
    
    UILabel *label=[[ UILabel alloc ] initWithFrame : CGRectMake ( 0 , view. frame . size . height - 1 , view. frame . size . width , 1 )];
    
    label. backgroundColor =[ UIColor whiteColor];
    
    [view addSubview :label];
    return view;
}
- (void)btnClick:(UIButton *)button {
    NSInteger section = button.tag - 101;
    //跟原来状态 取反
    _sectionStatus[section] = !_sectionStatus[section];
    //只刷新指定分区
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
}
//设置分区的高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

@end
