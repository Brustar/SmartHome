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
    if (self.itemID) {
        
        [self sendRequestForDetailMsgWithItemId:[_itemID intValue]];
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
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.msgArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"msgCell";
    MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.title.text = self.msgArr[indexPath.row];
        cell.timeLable.text = self.timesArr[indexPath.row];
    
 
    return cell;

}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
    NSMutableArray *deletedID =[NSMutableArray array];
    
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        
        [deleteArray addObject:self.msgArr[indexPath.row]];
        if (![deletedTime containsObject:self.timesArr[indexPath.row]]) {
              [deletedTime addObject:self.timesArr[indexPath.row]];
        }
      
        [deletedID addObject:self.recordID[indexPath.row]];
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
-(void)sendDeleteRequestWithArray:(NSArray *)deleteArr;
{
    NSString *url = [NSString stringWithFormat:@"%@EditPersonalInformation.aspx",[IOManager httpAddr]];
    
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
    
    
    NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"RecordIDList":recoreds,@"Type":[NSNumber numberWithInt:1]};
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
