//
//  ServiceRecordViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ServiceRecordViewController.h"
#import "ServiceRecordCell.h"
#import "IOManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
@interface ServiceRecordViewController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *commentView;

@property (nonatomic,strong) NSMutableArray *recoreds;
@property (nonatomic,strong) NSMutableArray *times;

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
    self.tableView.tableFooterView = [UIView new];
    self.coverView.hidden = YES;
    self.commentView.hidden = YES;
   // [self sendRequest];
    }
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
   // [self sendRequest];
}
-(void)sendRequest
{
    
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
    NSString *url = [NSString stringWithFormat:@"%@GetMaintainMessage.aspx",[IOManager httpAddr]];
    NSDictionary *dic = @{@"AuthorToken":auothorToken,@"UserID":userID};
    HttpManager *http=[HttpManager defaultManager];
   
    http.delegate = self;
    [http sendPost:url param:dic];
    
}
-(void)httpHandler:(id)responseObject
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
- (IBAction)clickGoodCommnet:(id)sender {
}

- (IBAction)clickStillHaveFault:(id)sender {
}
@end
