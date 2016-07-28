//
//  ServiceRecordViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ServiceRecordViewController.h"
#import "ServiceRecordCell.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
@interface ServiceRecordViewController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *commentView;

@property (nonatomic,strong) NSMutableArray *recoreds;
@property (nonatomic,strong) NSMutableArray *times;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (nonatomic,assign) BOOL isEditing;
- (IBAction)clickGoodCommnet:(id)sender;

- (IBAction)clickStillHaveFault:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *faultLabel;

@end

@implementation ServiceRecordViewController
-(NSMutableArray *)recoreds
{
    if(!_recoreds)
    {
        _recoreds = [NSMutableArray array];
    }
    return _recoreds;
}
-(NSMutableArray *)times
{
    if(!_times)
    {
        _times = [NSMutableArray array];
    }
    return  _times;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的维修";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footView;
    self.footView.hidden = YES;
    self.coverView.hidden = YES;
    self.commentView.hidden = YES;
    [self setNavi];
   // [self sendRequest];
    }

-(void)setNavi{
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(startEdit:)];
    self.navigationItem.rightBarButtonItem = editBtn;
    [self sendRequest];
}

-(void)sendRequest
{
    
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *userHostID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserHostID"];
    NSString *url = [NSString stringWithFormat:@"%@GetMaintainMessage.aspx",[IOManager httpAddr]];
    NSDictionary *dic = @{@"AuthorToken":auothorToken,@"UserHostID":userHostID};
    HttpManager *http=[HttpManager defaultManager];
   
    http.delegate = self;
    [http sendPost:url param:dic];
    
}
-(void)httpHandler:(id)responseObject
{
    if([responseObject[@"Result"] intValue]==0)
    {
        NSDictionary *dic = responseObject[@"messageInfo"];
        NSArray *msgList = dic[@"messageList"];
        for(NSDictionary *dicDetail in msgList)
        {
            NSString *description = dicDetail[@"description"];
            NSString *createDate = dicDetail[@"createDate"];
            [self.recoreds addObject:description];
            [self.times addObject:createDate];
        }
        [self.tableView reloadData];

    }else{
        [MBProgressHUD showError:responseObject[@"Msg"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recoreds.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ServiceRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceRecordCell" forIndexPath:indexPath];
    cell.title.text = self.recoreds[indexPath.row];
    cell.subTitle.text = self.times[indexPath.row];
    cell.evaluateBtn.tag = indexPath.row;
    [cell.evaluateBtn addTarget:self action:@selector(goToComment:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)goToComment:(UIButton *)btn
{
    self.coverView.hidden = NO;
    self.commentView.hidden = NO;
    self.faultLabel.text = self.recoreds[btn.tag];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)startEdit:(UIBarButtonItem *)barBtnItem
{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.footView.hidden = NO;
    self.isEditing = NO;
    [self.tableView reloadData];
}
- (IBAction)clickCancelDeleteBtn:(id)sender {
    
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    // 允许编辑
    self.tableView.editing = NO;
    //  self.tableView.tableFooterView = nil;
    self.footView.hidden = YES;
    self.isEditing = NO;
    [self.tableView reloadData];


}
- (IBAction)clickSureDeleteBtn:(id)sender {
    //放置要删除的对象
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSMutableArray *deletedTime = [NSMutableArray array];
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        //[deleteArray addObject:self.Mydefaults[indexPath.row]];
        [deleteArray addObject:self.recoreds[indexPath.row]];
        [deletedTime addObject:self.times[indexPath.row]];
    }
    // 先删除数据源
    [self.recoreds removeObjectsInArray:deleteArray];
    [self.times removeObjectsInArray:deletedTime];
    
    [self clickCancelDeleteBtn:nil];
}

- (IBAction)clickGoodCommnet:(id)sender {
}

- (IBAction)clickStillHaveFault:(id)sender {
}
@end
