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

@interface PushSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *sectionTitles;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UIView *pushTypeView;
@property (nonatomic,strong) UIButton *selectedBtn;
- (IBAction)selectPsuhTypeBtn:(UIButton *)sender;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) NSMutableArray *names;
@property (nonatomic,strong) NSMutableArray *typeNames;
@property (nonatomic,strong) NSMutableArray *notifyWay;
@property (nonatomic,strong) NSMutableArray *recordIDs;
@property (nonatomic,assign) NSInteger tag;
@end

@implementation PushSettingController
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
    UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
    self.navigationItem.leftBarButtonItem = returnItem;
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    [self sendRequest];
}

//获得所有设置请求
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@GetUserNotifySettings.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dict = @{@"AuthorToken":auothorToken};
    HttpManager *http=[HttpManager defaultManager];
    http.tag = 1;
    http.delegate = self;
    [http sendPost:url param:dict];
    
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"Result"] intValue]==0){
            NSArray *messageInfo = responseObject[@"messageInfo"];
            for(NSDictionary *typeName in messageInfo)
            {
                NSString *typeN = typeName[@"typeName"];
                [self.typeNames addObject:typeN];
                NSArray *infoList = typeName[@"infoList"];
                NSMutableArray *itemNames = [NSMutableArray array];
                NSMutableArray *itemIDs = [NSMutableArray array];
                NSMutableArray *records = [NSMutableArray array];
                for(NSDictionary *item in infoList)
                {
                    NSString *itemName = item[@"itemName"];
                    NSNumber *itemID = item[@"notifyWay"];
                    NSNumber  *recordID = item[@"recordId"];
                    [itemNames addObject:itemName];
                    [itemIDs addObject:itemID];
                    [records addObject:recordID];
                }
                [self.names addObject:itemNames];
                [self.notifyWay addObject:itemIDs];
                [self.recordIDs addObject:records];
            }
            [self.tableView reloadData];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }
 
    }else if(tag == 2)
    {
        if ([responseObject[@"Result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"修改成功"];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.typeNames.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *item = self.names[section];
    return item.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pushSettingCell" forIndexPath:indexPath];
    NSArray *item = self.names[indexPath.section];
    NSArray *notiWay = self.notifyWay[indexPath.section];
    cell.textLabel.text = item[indexPath.row];
    NSNumber *num = notiWay[indexPath.row];
    if([num intValue] == 1)
    {
        cell.detailTextLabel.text = @"信息";
    }else if([num intValue] == 2)
    {
        cell.detailTextLabel.text = @"短信";
    }else {
        cell.detailTextLabel.text = @"不通知";
    }
    
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1];
        UILabel *titleLabe = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 200, 50)];
        titleLabe.textColor = [UIColor grayColor];
        titleLabe.font = [UIFont systemFontOfSize:18];
        [view addSubview:titleLabe];
        titleLabe.text = self.typeNames[section];
        return view;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    self.coverView.hidden = NO;
    self.pushTypeView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


- (IBAction)selectPsuhTypeBtn:(UIButton *)sender {
    
        self.selectedBtn.selected = NO;
        [self.selectedBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        sender.selected = YES;
        self.selectedBtn = sender;
        [self.selectedBtn setImage:[UIImage imageNamed:@"correct"] forState:UIControlStateSelected];
        self.tag = sender.tag;
}
//设置通知类型请求
-(void)setUserNotifyWay:(NSInteger)way andRecord:(NSNumber *)recoredID
{
    
    NSString *url = [NSString stringWithFormat:@"%@NotificationSetting.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dict = @{@"AuthorToken":auothorToken,@"NotifyWay":[NSNumber numberWithInteger:way],@"RecordID":recoredID};
    HttpManager *http=[HttpManager defaultManager];
    http.tag = 2;
    http.delegate = self;
    [http sendPost:url param:dict];
}



- (IBAction)clickSureBtn:(id)sender {
    self.coverView.hidden = YES;
    self.pushTypeView.hidden = YES;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    NSArray *item = self.recordIDs[self.indexPath.section];
    NSNumber *recordID = item[self.indexPath.row];
    if(self.tag == 0)
    {
        cell.detailTextLabel.text = @"信息";
        [self setUserNotifyWay:1 andRecord:recordID];
        
    }else if(self.tag == 1)
    {
        cell.detailTextLabel.text = @"短信";
        [self setUserNotifyWay:2 andRecord:recordID];
    }else{
        cell.detailTextLabel.text = @"不通知";
        [self setUserNotifyWay:3 andRecord:recordID];
    }

    
}


- (IBAction)clickRetunBtn:(id)sender {
    //[self.view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];
}



@end