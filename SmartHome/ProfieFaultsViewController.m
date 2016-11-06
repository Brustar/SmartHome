//
//  ProfieFaultsViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ProfieFaultsViewController.h"
#import "ProfieFaultsCell.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "DeviceInfo.h"

@interface ProfieFaultsViewController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) BOOL isEditing;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic,strong) NSMutableArray *faultArr;
@property (nonatomic,strong) NSMutableArray *timesArr;
@property (nonatomic,strong) NSMutableArray *recordIDs;
- (IBAction)clickCancleBtn:(id)sender;
- (IBAction)clickSureBtn:(id)sender;


@end

@implementation ProfieFaultsViewController
-(NSMutableArray*)faultArr
{
    if(!_faultArr){
        _faultArr = [NSMutableArray array];
    }
    return _faultArr;
}
-(NSMutableArray *)timesArr{
    if(!_timesArr)
    {
        _timesArr = [NSMutableArray array];
        
    }
    return _timesArr;
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
    self.footerView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footerView;
    
    //获取所有故障信息
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"%@GetBreakdownMessage.aspx",[IOManager httpAddr]];
    
    if (auothorToken) {
        NSDictionary *dict = @{@"AuthorToken":auothorToken};
    
        [self sendRequest:url andDict:dict WithTag:1];
    }
}

-(void)sendRequest:(NSString *)url andDict:(NSDictionary *)dict WithTag:(int)tag
{
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dict];
    
    
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue]==0)
        {
            NSDictionary *dic = responseObject[@"messageInfo"];
            
            for(NSDictionary *dicDetail in dic)
            {
                [self.faultArr addObject:dicDetail[@"description"]];
                [self.timesArr addObject:dicDetail[@"createDate"]];
                [self.recordIDs addObject:dicDetail[@"status"]];
            }
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }else if(tag == 2){
        if([responseObject[@"Result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"上报成功"];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 3)
    {
        if([responseObject[@"Result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }


}


#pragma mark -UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.faultArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfieFaultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfieDefaultCell" forIndexPath:indexPath];
    
    cell.title.text = self.faultArr[indexPath.row];
    cell.dateLabel.text = self.timesArr[indexPath.row];
    
    if (self.isEditing) {
        cell.alertImageView.hidden = YES;
    }else{
        cell.alertImageView.hidden = NO;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
       if(!self.isEditing)
       {
           [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
           UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"发送故障信息" message:@"确定要发送此故障信息吗？" preferredStyle:UIAlertControllerStyleAlert];
           [self presentViewController:alertVC animated:YES completion:nil];
           UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               //确定后发送上传故障信息
               NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
               NSString *url = [NSString stringWithFormat:@"%@UploadBreakdown.aspx",[IOManager httpAddr]];
               NSString *recordID = self.recordIDs[indexPath.row];
               if (auothorToken) {
                   NSDictionary *dict = @{@"AuthorToken":auothorToken,@"RecordID":recordID};
                   [self sendRequest:url andDict:dict WithTag:2];
               }
           }];
           UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
               [alertVC dismissViewControllerAnimated:YES completion:nil];
           }];
           [alertVC addAction:sureAction];
           [alertVC addAction:cancleAction];

       }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (IBAction)clickEditBtn:(id)sender {
    
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    // 允许编辑
    self.tableView.editing = YES;
    
    self.footerView.hidden = NO;
    self.isEditing = YES;
    [self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



- (IBAction)clickCancleBtn:(id)sender {
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    // 允许编辑
    self.tableView.editing = NO;
    //  self.tableView.tableFooterView = nil;
    self.footerView.hidden = YES;
    self.isEditing = NO;
    [self.tableView reloadData];
}

- (IBAction)clickSureBtn:(id)sender {
    //放置要删除的对象
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSMutableArray *deletedTime = [NSMutableArray array];
    NSMutableArray *deletedID =[NSMutableArray array];
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        //[deleteArray addObject:self.Mydefaults[indexPath.row]];
        [deleteArray addObject:self.faultArr[indexPath.row]];
        [deletedTime addObject:self.timesArr[indexPath.row]];
        [deletedID addObject:self.recordIDs[indexPath.row]];
    }
    // 先删除数据源
    [self.faultArr removeObjectsInArray:deleteArray];
    [self.timesArr removeObjectsInArray:deletedTime];
    [self.recordIDs removeObject:deletedID];
    
    if(deletedID.count != 0)
    {
        [self sendDeleteRequestWithArray:[deletedID copy]];
    }else {
        [MBProgressHUD showError:@"请选择要删除的记录"];
    }

    
    [self clickCancleBtn:nil];
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
    
    
    NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"RecordIDList":recoreds,@"Type":[NSNumber numberWithInt:3]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 3;
    [http sendPost:url param:dic];
    
}


@end
