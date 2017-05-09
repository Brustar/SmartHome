//
//  MSGController.m
//  SmartHome
//
//  Created by Brustar on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MSGController.h"
#import "MsgCell.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "DetailMSGViewController.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface MSGController ()<HttpDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray * itemIdArrs;
@property (nonatomic,strong) NSMutableArray * actcodeArrs;
@property (nonatomic,strong) NSMutableArray * itemNameArrs;
@property (nonatomic,strong) NSMutableArray * unreadcountArr;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (nonatomic,assign) NSInteger unreadcount;
@property (nonatomic,strong) NSString * type;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray * array;
@property (nonatomic,strong) NSString *itemid;

@property (nonatomic,strong) NSMutableArray * msgArr;
@property (nonatomic,strong) NSMutableArray * timesArr;
@property (nonatomic,strong) NSMutableArray * recordID;
@property (nonatomic ,strong) NSMutableArray * isreadArr;

@end

@implementation MSGController
{
    int _sectionStatus[5];//默认:关闭
}
-(NSMutableArray *)msgArr
{
    if (!_msgArr) {
        _msgArr = [NSMutableArray array];
    }
    
    return _msgArr;
}
-(NSMutableArray *)timesArr
{
    if (!_timesArr) {
        _timesArr = [NSMutableArray array];
    }
    
    return _timesArr;
}
-(NSMutableArray *)recordID
{
    if (!_recordID) {
        _recordID = [NSMutableArray array];
    }
    
    return _recordID;
}
-(NSMutableArray *)isreadArr
{
    if (!_isreadArr) {
        _isreadArr = [NSMutableArray array];
    }
    
    return _isreadArr;
}
-(NSMutableArray *)unreadcountArr
{
    if (!_unreadcountArr) {
        _unreadcountArr = [NSMutableArray array];
    }

    return _unreadcountArr;
}

- (NSMutableArray *)actcodeArrs
{
    if (!_actcodeArrs) {
        _actcodeArrs = [NSMutableArray array];
    }
    return _actcodeArrs;
}

-(NSMutableArray *)itemIdArrs
{
    if (!_itemIdArrs) {
        _itemIdArrs = [NSMutableArray array];
    }

    return _itemIdArrs;
}
-(NSMutableArray *)itemNameArrs
{
    if (!_itemNameArrs) {
        _itemNameArrs = [NSMutableArray array];
    }

    return _itemNameArrs;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        [self.itemIdArrs removeAllObjects];
        [self.itemNameArrs removeAllObjects];
        [self.unreadcountArr removeAllObjects];
        [self creatItemID];
    }

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD hideHUD];
    [self setNaviBarTitle:@"通知"];
    _array = @[@"1",@"2",@"3"];
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
//        [self creatItemID];
    }else {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"msgTypeList" ofType:@"plist"]];
        NSArray *arr = plistDict[@"notify_type_list"];
        if ([arr isKindOfClass:[NSArray class]]) {
            for(NSDictionary *dicDetail in arr)
            {
                [self.itemIdArrs addObject:dicDetail[@"item_id"]];
                [self.actcodeArrs addObject:dicDetail[@"actcode"]];
                [self.itemNameArrs addObject:dicDetail[@"item_name"]];
                [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
            }
        }
        [self.tableView reloadData];
    }
    
}
-(void)sendRequestForDetailMsgWithItemId:(int)itemID
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:1],@"ItemID":[NSNumber numberWithInt:itemID]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 2;
        [http sendPost:url param:dic];
        
    }
}
-(void)creatItemID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:2]};
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
        if ([responseObject[@"result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"notify_type_list"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    [self.itemIdArrs addObject:dicDetail[@"item_id"]];
                    [self.itemNameArrs addObject:dicDetail[@"item_name"]];
                    [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
                }
            }
            
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    } if(tag == 2)
    {
        if ([responseObject[@"result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"notify_list"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    if ([dicDetail isKindOfClass:[NSDictionary class]] && dicDetail[@"description"]) {
                        [self.msgArr addObject:dicDetail[@"description"]];
                        [self.timesArr addObject:dicDetail[@"addtime"]];
                        [self.recordID addObject:dicDetail[@"notify_id"]];
                        [self.isreadArr addObject:dicDetail[@"isread"]];
                    }
                }
            }
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

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
//每组有多少cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
 return self.itemIdArrs.count;
}
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//     return self.itemIdArrs.count;
//}
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString * str = self.itemIdArrs[section];
//    
//    return str;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if (_sectionStatus[section]) { //1表示展开 0表示收起
//        //表示展开
//        return [_msgArr count];
//    }else{
//        return 0;//0行
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"msgCell";
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    cell.title.text = self.itemNameArrs[indexPath.row];
    cell.countLabel.text = [NSString stringWithFormat:@"%@",self.unreadcountArr[indexPath.row]];
    self.unreadcount = [self.unreadcountArr[indexPath.row] integerValue];
    if (self.unreadcount == 0) {
        cell.unreadcountImage.hidden = YES;
        cell.countLabel.hidden       = YES;
    }else{
        cell.unreadcountImage.hidden = NO;
        cell.countLabel.hidden       = NO;

    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    UIStoryboard * oneStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DetailMSGViewController * MSGVC = [oneStoryBoard instantiateViewControllerWithIdentifier:@"DetailMSGViewController"];
    _itemid = self.itemIdArrs[indexPath.row];
    MSGVC.itemID = _itemid;
      DeviceInfo *device = [DeviceInfo defaultManager];
    if (![device.db isEqualToString:SMART_DB]){
        MSGVC.actcode = self.actcodeArrs[indexPath.row];
    }
   
    [self.navigationController pushViewController:MSGVC animated:YES];
}

//编辑操作
-(void)startEdit:(UIBarButtonItem *)btn
{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.footView.hidden = NO;
    [self.tableView reloadData];
}
//#pragma mark 分区的头视图
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (self.tableView != tableView) {
//        return nil;
//    }
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 40)];
//    view.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(kScreenSize.width-40, 0, 30, 30);
//    button.tag = 101+section;
//    if (_sectionStatus[section] == 0) {
//        [button setImage:[UIImage imageNamed:@"icon_dd_normal"] forState:UIControlStateNormal];
//    }else{
//        [button setImage:[UIImage imageNamed:@"messageUp"] forState:UIControlStateNormal];
////         _itemid = self.itemIdArrs[section];
////         [self sendRequestForDetailMsgWithItemId:[_itemid intValue]];
//    }
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:button];
//   
//    //推送的名字
//    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
//    nameLabel.textAlignment = NSTextAlignmentLeft;
//    nameLabel.textColor = [UIColor whiteColor];
//    nameLabel.backgroundColor = [UIColor clearColor];
//    [nameLabel setText:self.itemNameArrs[section]];
//    [view addSubview:nameLabel];
//    //未读消息的label
//    UILabel * countLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 20, 20)];
//    countLabel.textAlignment = NSTextAlignmentCenter;
//    countLabel.layer.cornerRadius = 10;
//    countLabel.layer.masksToBounds = YES;
//    countLabel.textColor = [UIColor whiteColor];
//    countLabel.font = [UIFont systemFontOfSize:13];
//    countLabel.backgroundColor = [UIColor redColor];
////    [countLabel setText:self.itemNameArrs[section]];
//    countLabel.text = [NSString stringWithFormat:@"%ld",(long)[self.unreadcountArr[section] integerValue]];
//    self.unreadcount = [self.unreadcountArr[section] integerValue];
//    if (self.unreadcount == 0) {
//        countLabel.hidden = YES;
//    }else{
//        countLabel.hidden = NO;
//    }
//    [view addSubview:countLabel];
//    
//    //上显示线
//    
//    UILabel *label1=[[ UILabel alloc ] initWithFrame : CGRectMake ( 0 , - 1 , view. frame . size . width , 1 )];
//    
//    label1. backgroundColor =[ UIColor whiteColor];
//    
//    [view addSubview :label1];
//    
//    //下显示线
//    
//    UILabel *label=[[ UILabel alloc ] initWithFrame : CGRectMake ( 0 , view. frame . size . height - 1 , view. frame . size . width , 1 )];
//    
//    label. backgroundColor =[ UIColor whiteColor];
//    
//    [view addSubview :label];
//    return view;
//}
//- (void)btnClick:(UIButton *)button {
//    NSInteger section = button.tag - 101;
//      _itemid = self.itemIdArrs[section];
//    //跟原来状态 取反
//    _sectionStatus[section] = !_sectionStatus[section];
//    if (_sectionStatus[section]) {
//      
//        [self sendRequestForDetailMsgWithItemId:[_itemid intValue]];
//    }
//    //只刷新指定分区
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
//}
//设置分区的高
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 40;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
@end
