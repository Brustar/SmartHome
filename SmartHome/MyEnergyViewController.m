//
//  MyEnergyViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MyEnergyViewController.h"
#import "MyEnergyCell.h"
#import "DetailList.h"
#import "EnergyOfDeviceController.h"
#import "HttpManager.h"
#import "DeviceManager.h"
#import "Device.h"
#import "DeviceInfo.h"
#import "MBProgressHUD+NJ.h"


#define CellItemCol 2
#define CellItemMarginY 10
#define CellItemViewHeight 50
#define CellItemViewWidth  120

@interface MyEnergyViewController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (nonatomic,strong) NSMutableArray *energys;
@property (nonatomic,strong) NSMutableArray *times;
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,strong) EnergyOfDeviceController *engerOfDeviceVC;
- (IBAction)clickCancleBtn:(id)sender;

- (IBAction)clickSureBtn:(id)sender;
//选择设备能耗属性
@property (weak, nonatomic) IBOutlet UITableView *selectedDeviceTableView;
@property (nonatomic,strong) NSArray *deviceType;
@property (nonatomic,strong) NSArray *subDevice;
@property (nonatomic,strong) NSArray *devicesInfo;

@property (nonatomic,strong) NSMutableArray *enegers;
@property (nonatomic,strong) NSString *overEneger;

@end

@implementation MyEnergyViewController


//-(NSArray *)devicesInfo{
//    if(!_devicesInfo)
//    {
//        _devicesInfo = [DeviceManager getAllDevicesInfo];
//    }
//    return _devicesInfo;
//}

-(NSMutableArray *)enegers
{
    if(!_enegers)
    {
        _enegers = [NSMutableArray array];
        
    }
    return _enegers;
}
-(void)sendRequestToGetEenrgy
{
    NSString *url = [NSString stringWithFormat:@"%@EnergyAnalysis.aspx",[IOManager httpAddr]];
    NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag =1;
    [http sendPost:url param:dic];
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"messageInfo"];
            NSDictionary *overDic = @{@"overEngry":responseObject[@"energyPoor"]};
            for(NSDictionary *dic in message)
            {
                NSDictionary *energy = @{@"ename":dic[@"ename"],@"hour":dic[@"minute_time"],@"times":dic[@"number"],@"energy":dic[@"energy"]};
                
                [self.enegers addObject:energy];
                
            }
            [self.enegers addObject:overDic];
            [self.tableView reloadData];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的能耗";
    self.enegers = [NSMutableArray array];
    self.footView.hidden = YES;
    [self setNavi];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footView;
    self.selectedDeviceTableView.tableFooterView = [UIView new];
    
    [self sendRequestToGetEenrgy];
    
   // self.deviceType = [DeviceManager getAllDeviceSubTypes];
    
    self.selectedDeviceTableView.hidden = YES;
    
    
}

-(void)setNavi
{
    UIBarButtonItem *listItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"memu"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedDevice:)];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(clickEditBtn:)];
    self.navigationItem.rightBarButtonItems = @[listItem,editItem];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if(tableView == self.selectedDeviceTableView)
//    {
//        return self.deviceType.count + 1;
//    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(tableView == self.selectedDeviceTableView)
//    {
//        return 1;
//    }
    return self.enegers.count;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        
        MyEnergyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyEnergyCell" forIndexPath:indexPath];
       
        NSDictionary *dic = self.enegers[indexPath.row];
        
        if(indexPath.row == self.enegers.count - 1)
        {
            cell.titleLabel.text = @"本月总能耗超出上月";
            cell.timeLabel.text = [NSString stringWithFormat:@"超出上月的能耗:%@",dic[@"overEngry"]];
            cell.totalLabel.text = @"";
        }else{
            NSString *ename = dic[@"ename"];
            int hour = [dic[@"hour"] intValue];
            int times = [dic[@"times"] intValue];
            
            NSString *energy = dic[@"energy"];
            cell.totalLabel.text = energy ;
            
            switch (indexPath.row) {
                case 0:
                {
                    
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@使用时间最长",ename];
                    cell.timeLabel.text = [NSString stringWithFormat:@"累计时间:%d分钟",hour];
                }
                    break;
                case 1:
                {
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@能耗最大",ename];
                    cell.timeLabel.text = [NSString stringWithFormat:@"累计使用:%d分钟",hour];
                }
                    break;
                default:
                {
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@使用次数最多",ename];
                    cell.timeLabel.text = [NSString stringWithFormat:@"累计使用次数:%d",times];
                }
                    break;
                
            }

        }
                return cell;
    
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//            if(indexPath.section == 0)
//            {
//                NSArray *arrry = @[@"全部设备"];
//                [self setButtnonInCell:cell andSubDevie:arrry];
//            }else{
//                NSString *typeName = self.deviceType[indexPath.section -1];
//                NSArray *deviceNames = [DeviceManager getAllDeviceNameBysubType:typeName];
//                [self setButtnonInCell:cell andSubDevie:deviceNames];
//            }
            
        
        }
        
        return cell;
    }


 
}

-(void)goToEngerOfDevice:(UIButton *)btn
{
    self.engerOfDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EnergyOfDeviceController"];
    self.engerOfDeviceVC.eId = btn.tag;
    [self.navigationController pushViewController:self.engerOfDeviceVC animated:NO];
    
}

- (CGFloat)tableViewCellHeight:(NSInteger)itemCount
{
    return CellItemMarginY + (CellItemMarginY + CellItemViewHeight) * ( (itemCount + CellItemCol - 1) / CellItemCol );
}


//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(tableView == self.selectedDeviceTableView)
//    {
//        //NSArray *b = A[indexPath.section];
//        //return [self tableViewCellHeight:b.count]
//        if(indexPath.section == 0)
//        {
//            return 44;
//        }
//        NSString *typeName = self.deviceType[indexPath.section];
//        NSArray *deviceNames = [DeviceManager getAllDeviceNameBysubType:typeName];
//        return [self tableViewCellHeight:deviceNames.count];
//    }
//    return 44;
//    
//}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if(tableView == self.selectedDeviceTableView)
//    {
//        if(section == 0)
//        {
//            return nil;
//        }else {
//            return self.deviceType[section];
//
//        }
//        
//    }
//    
//    return nil;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//- (IBAction)clickEditBtn:(id)sender {
//    // 允许多个编辑
//    self.tableView.allowsMultipleSelectionDuringEditing = YES;
//    // 允许编辑
//    self.tableView.editing = YES;
//    
//    self.footView.hidden = NO;
//    self.isEditing = YES;
//    [self.tableView reloadData];
//}
//
//- (IBAction)clickCancleBtn:(id)sender {
//    // 允许多个编辑
//    self.tableView.allowsMultipleSelectionDuringEditing = NO;
//    // 允许编辑
//    self.tableView.editing = NO;
//    //  self.tableView.tableFooterView = nil;
//    self.footView.hidden = YES;
//    self.isEditing = NO;
//    [self.tableView reloadData];
//
//}
//
//- (IBAction)clickSureBtn:(id)sender {
//    //放置要删除的对象
//    NSMutableArray *deleteArray = [NSMutableArray array];
//    NSMutableArray *deletedTime = [NSMutableArray array];
//    // 要删除的row
//    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
//    
//    for (NSIndexPath *indexPath in selectedArray) {
//        //[deleteArray addObject:self.Mydefaults[indexPath.row]];
//        [deleteArray addObject:self.energys[indexPath.row]];
//        [deletedTime addObject:self.times[indexPath.row]];
//    }
//    // 先删除数据源
//    [self.energys removeObjectsInArray:deleteArray];
//    [self.times removeObjectsInArray:deletedTime];
//    
//    [self clickCancleBtn:nil];
//
//}

//- (IBAction)selectedDevice:(id)sender {
//    self.selectedDeviceTableView.hidden = !self.selectedDeviceTableView.hidden;
//}
//
//-(void)removeAllSubViewFromMyEnergyViewController
//{
//    [self.engerOfDeviceVC.view removeFromSuperview];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//   
//}

@end
