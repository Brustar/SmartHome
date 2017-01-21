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
@property (nonatomic,strong) NSMutableArray *recordIDS;
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
-(NSMutableArray *)recordIDS
{
    if(!_recordIDS)
    {
        _recordIDS = [NSMutableArray array];
    }
    return _recordIDS;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的保修记录";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footView;
    self.footView.hidden = YES;
    self.coverView.hidden = YES;
    self.commentView.hidden = YES;
    self.isEditing = YES;
    [self setNavi];
}

-(void)setNavi{
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(startEdit:)];
    self.navigationItem.rightBarButtonItem = editBtn;
    
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *str = FIX_URL;
    if (auothorToken) {
        NSDictionary *dic = @{@"token":auothorToken,@"optype":@(1)};
        [self sendRequest:dic andUrlStr:str with:1];
    }else { //体验
        self.navigationItem.rightBarButtonItem = nil;
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"maintaininfo" ofType:@"plist"]];
        NSArray *arr = plistDict[@"break_down_list"];
        
        for(NSDictionary *dicDetail in arr)
        {
            [self.recoreds addObject:dicDetail[@"description"]];
            [self.times addObject:dicDetail[@"createdate"]];
            [self.recordIDS addObject:dicDetail[@"breakdown_id"]];
        }
        [self.tableView reloadData];
    }
}

-(void)sendRequest:(NSDictionary *)dic andUrlStr:(NSString *)str with:(int)tag
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    HttpManager *http=[HttpManager defaultManager];
   
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
    
}

- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            NSArray *arr = responseObject[@"maintain_info"][@"break_down_list"];
            
            for(NSDictionary *dicDetail in arr)
            {
                [self.recoreds addObject:dicDetail[@"description"]];
                [self.times addObject:dicDetail[@"createdate"]];
                [self.recordIDS addObject:dicDetail[@"breakdown_id"]];
            }
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }

    }else if(tag == 2)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"评价成功"];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
        self.coverView.hidden = YES;
        self.commentView.hidden = YES;
    }else if(tag == 3)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
            
        }else {
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
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
    if (self.times.count>indexPath.row) {
        cell.subTitle.text = self.times[indexPath.row];
    }
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
    NSMutableArray *deletedID =[NSMutableArray array];
    
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        
        [deleteArray addObject:self.recoreds[indexPath.row]];
        [deletedTime addObject:self.times[indexPath.row]];
        [deletedID addObject:self.recordIDS[indexPath.row]];
    }
    // 先删除数据源
    [self.recoreds removeObjectsInArray:deleteArray];
    [self.times removeObjectsInArray:deletedTime];
    [self.recordIDS removeObject:deletedID];
    
    if(deletedID.count != 0)
    {
        [self sendDeleteRequestWithArray:[deletedID copy]];
    }else {
        [MBProgressHUD showError:@"请选择要删除的记录"];
    }

    
    [self clickCancelDeleteBtn:nil];
    
    [self.tableView reloadData];
}

-(void)sendDeleteRequestWithArray:(NSArray *)deleteArr;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],FIX_URL];
   
    NSString *recoreds = @"";
    
    for(int i = 0 ;i < deleteArr.count; i++)
    {
        if(i == deleteArr.count - 1)
        {
            NSString *record = [NSString stringWithFormat:@"%@",deleteArr[i]];
            recoreds = [recoreds stringByAppendingString:record];

        }else {
            NSString *record = [NSString stringWithFormat:@"%@,",deleteArr[i]];
            recoreds = [recoreds stringByAppendingString:record];
        }
    }
    
  
    NSDictionary *dic = @{@"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ids":recoreds,@"optype":[NSNumber numberWithInt:4]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 3;
    [http sendPost:url param:dic];
    
}
//好评
- (IBAction)clickGoodCommnet:(id)sender {
    
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
    
         [self sendCommentType:1];
    }else { //体验
        [MBProgressHUD showSuccess:@"评价成功"];
        self.coverView.hidden = YES;
        self.commentView.hidden = YES;
    }
   
}

//还有故障
- (IBAction)clickStillHaveFault:(id)sender {
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        [self sendCommentType:2];
    }else {  //体验
        [MBProgressHUD showSuccess:@"评价成功"];
        self.coverView.hidden = YES;
        self.commentView.hidden = YES;
    }
}

//评价
-(void)sendCommentType:(int)type
{
    NSDictionary *dic = @{@"token":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"breakdown_id":[NSNumber numberWithInt:1],@"optype":[NSNumber numberWithInt:type]};
    [self sendRequest:dic andUrlStr:FIX_URL with:2];
}

@end
