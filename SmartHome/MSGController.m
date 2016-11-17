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
@interface MSGController ()<HttpDelegate>
@property(nonatomic,strong) NSMutableArray *msgArr;
@property(nonatomic,strong) NSMutableArray *timesArr;
@property(nonatomic,strong) NSMutableArray *ItemID;
@property (nonatomic,strong)NSMutableArray *recordID;
@property (weak, nonatomic) IBOutlet UIView *footView;

@end

@implementation MSGController
-(NSMutableArray *)msgArr
{
    if(!_msgArr)
    {
        _msgArr = [NSMutableArray array];
        
    }
    return _msgArr;
}
-(NSMutableArray *)timesArr
{
    if(!_timesArr)
    {
        _timesArr = [NSMutableArray array];
    }
    return _timesArr;
}
-(NSMutableArray *)ItemID
{
    if(!_ItemID)
    {
        _ItemID = [NSMutableArray array];
    }
    return _ItemID;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD hideHUD];
    self.title = @"我的消息";
    self.tableView.tableFooterView = self.footView;
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(startEdit:)];
    self.navigationItem.rightBarButtonItem = editBtn;
    [self sendRequest];
   
}

-(void)sendRequest
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
  
    NSString *url = [NSString stringWithFormat:@"%@GetNotifyMessage.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"AuthorToken":authorToken};
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
        if ([responseObject[@"Result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"messageInfo"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    if ([dicDetail isKindOfClass:[NSDictionary class]]) {
                        [self.msgArr addObject:dicDetail[@"description"]];
                        [self.timesArr addObject:dicDetail[@"createDate"]];
                        [self.recordID addObject:dicDetail[@"recordID"]];
                    }
                }
            }
            
            
            
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }

    
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

//编辑操作
-(void)startEdit:(UIBarButtonItem *)btn
{
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.footView.hidden = NO;
    [self.tableView reloadData];
}
- (IBAction)clickCancelBtn:(id)sender {
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    // 允许编辑
    self.tableView.editing = NO;
    //  self.tableView.tableFooterView = nil;
    self.footView.hidden = YES;
   
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
        [deletedTime addObject:self.timesArr[indexPath.row]];
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


@end
