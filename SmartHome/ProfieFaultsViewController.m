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
#import "IOManager.h"

@interface ProfieFaultsViewController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) BOOL isEditing;
@property (weak, nonatomic) IBOutlet UIView *footerView;
- (IBAction)clickCancleBtn:(id)sender;
- (IBAction)clickSureBtn:(id)sender;


@end

@implementation ProfieFaultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.footerView.hidden = YES;
    self.Mydefaults = [NSMutableArray arrayWithObjects:@"123", @"345", @"4324", nil];
    self.tableView.tableFooterView = self.footerView;
    
    [self sendRequest];
    
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@GetMyBreakdown. ashx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
}

#pragma mark -UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.Mydefaults.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfieFaultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfieDefaultCell" forIndexPath:indexPath];
    
    cell.title.text = self.Mydefaults[indexPath.row];
    cell.dateLabel.text = @"2016-7-9";
    
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
           UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               //确定后发送上传故障信息
           }];
           UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
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
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        [deleteArray addObject:self.Mydefaults[indexPath.row]];
    }
    // 先删除数据源
    [self.Mydefaults removeObjectsInArray:deleteArray];
    
    [self clickCancleBtn:nil];
}


@end
