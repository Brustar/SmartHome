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
#import "ECMessage.h"
#import "LeftViewController.h"

@interface DetailMSGViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray * msgArr;
@property (nonatomic,strong) UIButton * leftBtn;
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) NSInteger notify_id;
@property (nonatomic,assign) NSInteger unreadcount;
@property (nonatomic,strong) UIImageView * image;
@property (nonatomic,strong) UILabel * label;
@property (nonatomic,strong) UIButton * naviRightBtn;

@property (nonatomic,assign) int selectId;

@end

@implementation DetailMSGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.type = @"1";
    _msgArr = [NSMutableArray array];
    self.isEditing = YES;
    if (self.itemID) {
         [self setupNaviBar];
         [self sendRequestForDetailMsgWithItemId:_itemID];
    }
    
    [self createImage];
}
- (void)setupNaviBar {
   
    [self setNaviBarTitle:@"消息通知"];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"编辑" target:self action:@selector(rightBtnClicked:)];
    if (ON_IPAD) {
          _leftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"backBtn" imgHighlight:@"backBtn" target:self action:@selector(leftBtnClicked:)];
         [self setNaviBarLeftBtn:_leftBtn];
    }
    
    [self setNaviBarRightBtn:_naviRightBtn];
   

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
}
-(void)leftBtnClicked:(UIButton *)btn
{
     [self.navigationController popViewControllerAnimated:YES];
//     LeftViewController * leftVC = [[LeftViewController alloc] init];
//     [leftVC refreshUI];
   
    
}
-(void)rightBtnClicked:(UIButton *)btn
{
    if (btn.selected) {
        btn.selected = NO;
        [_naviRightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self clickDeleteBtn:nil];
    }else{
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        self.tableView.editing = YES;
        self.isEditing = NO;
        [self.tableView reloadData];
    }
}

-(void)createImage
{
    self.image = [[UIImageView alloc] init];
    self.image.image = [UIImage imageNamed:@"PL"];
    self.image.hidden = YES;
    self.label = [[UILabel alloc]init];
    self.label.hidden = YES;
    self.label.numberOfLines = 0;
    self.label.text = @"暂时没有任何消息提醒";
    self.label.textColor = [UIColor colorWithRed:132/255.0 green:132/255.0 blue:133/255.0 alpha:1];
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
                        ECMessage *msg = [ECMessage new];
                        msg.descr = [dicDetail[@"description"] description];
                        msg.atime = dicDetail[@"addtime"];
                        msg.MID = [dicDetail[@"notify_id"] intValue];
                        msg.readed = [dicDetail[@"isread"] intValue];
                        [self.msgArr addObject:msg];
                    }
                }
            }
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 2)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
            self.tableView.editing = NO;

        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if (tag == 3){
        if ([responseObject[@"result"] intValue] == 0) {
            //self.isreadArr[self.selectId] = @"1";
//            [self sendRequestForDetailMsgWithItemId:_itemID];
        }else {
            
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.msgArr.count == 0) {
        self.image.hidden = NO;
        self.label.hidden = NO;
    }else{
        self.image.hidden = YES;
        self.label.hidden = YES;
    }
    return self.msgArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"msgCell";
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (self.msgArr.count >= indexPath.row) {
        ECMessage *msg = self.msgArr[indexPath.row];
        cell.timeLable.text = msg.atime;
        self.itemID = msg.MID;
        self.unreadcount = msg.readed;
        cell.title.text = msg.descr;
        cell.title.adjustsFontSizeToFitWidth = YES;
        cell.title.textColor = [UIColor whiteColor];
        cell.timeLable.textColor = [UIColor whiteColor];
    }
    if (self.unreadcount == 0) {//未读消息
        cell.unreadcountImage.hidden = YES;
        cell.countLabel.hidden       = YES;
//        [self sendRequestForMsgWithItemId:self.itemID];
        
    }else if(self.unreadcount == 1){
        cell.unreadcountImage.hidden = YES;
        cell.countLabel.hidden       = YES;
    }
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    cell.selectedBackgroundView = view;
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !self.isEditing;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectId = (int)indexPath.row;
    if (self.isEditing){
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        ECMessage *msg = self.msgArr[indexPath.row];
        self.notify_id = msg.MID;
        if (msg.readed==0) {
            
//            [self sendRequestForMsgWithItemId:_itemID];
        }
    }
    
    NSArray *selectedArray = [tableView indexPathsForSelectedRows];
    if ([selectedArray count]>0) {
        _naviRightBtn.selected = YES;
        [_naviRightBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedArray = [tableView indexPathsForSelectedRows];
    if ([selectedArray count] == 0) {
        _naviRightBtn.selected = NO;
        [_naviRightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (IBAction)clickDeleteBtn:(id)sender {
    //放置要删除的对象
    NSMutableArray *deleteArray = [NSMutableArray array];
    
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        if (self.msgArr[indexPath.row]) {
              [deleteArray addObject:self.msgArr[indexPath.row]];
        }
    }
    // 先删除数据源
    for (id obj in deleteArray) {
        [self.msgArr removeObject:obj];
    }
    
    if(deleteArray.count != 0)
    {
        [self sendDeleteRequestWithArray:[deleteArray copy]];
    }else {
        [MBProgressHUD showError:@"请选择要删除的记录"];
    }
    [self.tableView reloadData];
    
}

-(void)leftEdit:(UIBarButtonItem *)bbi
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendRequestForMsgWithItemId:(NSInteger)itemID
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:5],@"itemid":[NSNumber numberWithInteger:itemID]};
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
        ECMessage *msg = deleteArr[i];
        if(i == deleteArr.count - 1)
        {
            NSString *record = [NSString stringWithFormat:@"%d",msg.MID];
            recoreds = [recoreds stringByAppendingString:record];
        }else {
            NSString *record = [NSString stringWithFormat:@"%d,",msg.MID];
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
