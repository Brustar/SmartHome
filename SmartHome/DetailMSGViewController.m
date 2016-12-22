//
//  DetailMSGViewController.m
//  SmartHome
//
//  Created by zhaona on 2016/11/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DetailMSGViewController.h"
#import "MsgCell.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface DetailMSGViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *FootView;
@property (nonatomic,strong) NSMutableArray * msgArr;
@property (nonatomic,strong) NSMutableArray * timesArr;
@property (nonatomic,strong) NSMutableArray * recordID;
@property (nonatomic ,strong) NSMutableArray * isreadArr;
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) NSInteger notify_id;
@property (nonatomic,assign) NSInteger unreadcount;
@property (nonatomic,strong) UIImageView * image;
@property (nonatomic,strong) UILabel * label;

@end

@implementation DetailMSGViewController
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = self.FootView;
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(startEdit:)];
    self.navigationItem.rightBarButtonItem = editBtn;
//    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"我的消息" style:UIBarButtonItemStylePlain target:self action:@selector(leftEdit:)];
//    self.navigationItem.leftBarButtonItem = leftBtn;
    
     self.isEditing = YES;
    if (self.itemID) {
        
        [self sendRequestForDetailMsgWithItemId:[_itemID intValue]];
    }
    
    [self createImage];
}

-(void)createImage
{
    self.image = [[UIImageView alloc] init];
    self.image.image = [UIImage imageNamed:@"PL"];
    [self.view addSubview:self.image];
    [self addPicConstraint];
    self.image.hidden = YES;
    self.label = [[UILabel alloc]init];
    self.label.hidden = YES;
    self.label.numberOfLines = 0;
    self.self.label.text = @"暂时没有任何消息提醒";
    self.self.label.textColor = [UIColor lightGrayColor];
    [self addLabelConstraint];
    [self.view addSubview:self.self.label];
   
}

-(void)addLabelConstraint
{
    //使用代码布局 需要将这个属性设置为NO
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    //创建x居中的约束
    NSLayoutConstraint * constraintx = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    //创建y居中的约束
    NSLayoutConstraint * constrainty = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    //创建宽度约束
    NSLayoutConstraint * constraintw = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200];
    //创建高度约束
    NSLayoutConstraint * constrainth = [NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200];
    //添加约束之前，必须将视图加在父视图上
    [self.view addSubview:self.label];
    [self.view addConstraints:@[constraintx,constrainty,constrainth,constraintw]];

}
- (void)addPicConstraint{
    
    //禁用antoresizing
    
    _image.translatesAutoresizingMaskIntoConstraints = NO;
    
    //添加高约束
    
    NSLayoutConstraint *picHeight = [NSLayoutConstraint constraintWithItem:_image attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:70];
    
    [_image addConstraint:picHeight];
    
    //添加宽约束
    
    NSLayoutConstraint *picWeight = [NSLayoutConstraint constraintWithItem:_image attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:70];
    
    [_image addConstraint:picWeight];
    
    //添加y方向约束
    
    NSLayoutConstraint *picTop = [NSLayoutConstraint constraintWithItem:_image attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_image.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:160];
    [self.view addConstraint:picTop];
    
    //添加x方向约束
    
    NSLayoutConstraint *picVer = [NSLayoutConstraint constraintWithItem:_image attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_image.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    [self.view addConstraint:picVer];
    
}

-(void)sendRequestForDetailMsgWithItemId:(int)itemID
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:1],@"ItemID":[NSNumber numberWithInt:itemID]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dic];
        
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
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
    }else if(tag == 2)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if (tag == 3){
        if ([responseObject[@"result"] intValue] == 0) {
             [MBProgressHUD showSuccess:@"消息已读"];
            
        }else {
            
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.msgArr.count == 0) {
        self.image.hidden = NO;
        self.self.label.hidden = NO;
    }else{
        self.image.hidden = YES;
        self.self.label.hidden = YES;
    }
    return self.msgArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"msgCell";
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.title.text = self.msgArr[indexPath.row];
        cell.timeLable.text = self.timesArr[indexPath.row];
        self.itemID = self.recordID[indexPath.row];
        cell.tag = [self.msgArr[indexPath.row] integerValue];
        self.unreadcount = [self.isreadArr[indexPath.row] integerValue];
    if (self.unreadcount == 0) {//未读消息
        cell.unreadcountImage.hidden = NO;
        cell.countLabel.hidden       = NO;
    }else if(self.unreadcount == 1){
        cell.unreadcountImage.hidden = YES;
        cell.countLabel.hidden       = YES;
    }
    return cell;

}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing == NO) {
        return YES;
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing==NO) {
        return;
    }else if (self.isEditing == YES){
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.notify_id = [self.recordID[indexPath.row] integerValue];
        if ([self.isreadArr[indexPath.row] integerValue]==0) {
             [self sendRequestForMsgWithItemId:self.notify_id];
        }
       
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (IBAction)clickCancelBtn:(id)sender {
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    // 允许编辑
    self.tableView.editing = NO;
    //  self.tableView.tableFooterView = nil;
    self.FootView.hidden = YES;
    
    [self.tableView reloadData];
    
}
- (IBAction)clickDeleteBtn:(id)sender {
    //放置要删除的对象
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSMutableArray *deletedTime = [NSMutableArray array];
    NSMutableArray *deletedID   = [NSMutableArray array];
    
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        if (self.msgArr[indexPath.row]) {
              [deleteArray addObject:self.msgArr[indexPath.row]];
        }
      
        if (![deletedTime containsObject:self.timesArr[indexPath.row]]) {
              [deletedTime addObject:self.timesArr[indexPath.row]];
        }
        if (self.recordID[indexPath.row]) {
            [deletedID addObject:self.recordID[indexPath.row]];
        }
        
    }
    // 先删除数据源
    [self.msgArr removeObjectsInArray:deleteArray];
    [self.timesArr removeObjectsInArray:deletedTime];
    
    if(deletedID.count != 0)
    {
        [self sendDeleteRequestWithArray:[deletedID copy]];
    }else {
        [MBProgressHUD showError:@"请选择要删除的记录"];
    }
       [self clickCancelBtn:nil];
    
}
-(void)startEdit:(UIBarButtonItem *)barBtnItem
{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.FootView.hidden = NO;
    self.isEditing = NO;
    [self.tableView reloadData];
}

-(void)leftEdit:(UIBarButtonItem *)bbi
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self sendRequestForMsgWithItemId:self.notify_id];

}
-(void)sendRequestForMsgWithItemId:(NSInteger)itemID
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:5],@"notify_id":[NSNumber numberWithInteger:itemID]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 3;
        [http sendPost:url param:dic];
    }
}
-(void)sendDeleteRequestWithArray:(NSArray *)deleteArr;
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    
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
    http.tag = 2;
    [http sendPost:url param:dic];
    
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
