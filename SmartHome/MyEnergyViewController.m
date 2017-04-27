//
//  MyEnergyViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MyEnergyViewController.h"
#import "MyEnergyCell.h"

#import "EnergyOfDeviceController.h"
#import "HttpManager.h"
#import "SQLManager.h"
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
@property (nonatomic,strong) NSMutableArray *deviceIDs;
@property (nonatomic,strong) NSArray *subDevice;
@property (nonatomic,strong) NSArray *devicesInfo;
@property (nonatomic,strong) NSMutableArray * deviceTypes;
@property (nonatomic,strong) NSMutableArray *enegers;
@property (nonatomic,strong) NSString *overEneger;

@end

@implementation MyEnergyViewController


-(NSArray *)devicesInfo{
    if(!_devicesInfo)
    {
        _devicesInfo = [SQLManager getAllDevicesInfo];
    }
    return _devicesInfo;
}

-(NSMutableArray *)enegers
{
    if(!_enegers)
    {
        _enegers = [NSMutableArray array];
        
    }
    return _enegers;
}
-(NSMutableArray *)energys
{

    if (!_energys) {
        _energys = [NSMutableArray array];
    }

    return _energys;
}
-(void)sendRequestToGetEenrgy
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/energy_list.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:0]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        [http sendPost:url param:dic];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"energy_stat_list"];
            NSDictionary *overDic = @{@"energy_poor":responseObject[@"energy_poor"]};
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
    self.selectedDeviceTableView.sectionHeaderHeight = 44;
    
    [self sendRequestToGetEenrgy];
    
    self.deviceType = [SQLManager getAllDeviceSubTypes];
    self.deviceTypes = [NSMutableArray arrayWithArray:self.deviceType];
    NSArray * arr = @[@"感应器",@"影音",@"智能单品"];
    if (![arr containsObject:self.deviceTypes]) {
        [self.deviceTypes removeObjectsInArray:arr];
    }
   
    self.selectedDeviceTableView.hidden = YES;
    self.deviceIDs = [NSMutableArray array];
    
    for (NSString *subName in self.deviceTypes) {
        NSArray *subNameID = [SQLManager getDeviceIDBySubName:subName];
        [self.deviceIDs addObject:subNameID];
    }
    
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
    if(tableView == self.selectedDeviceTableView)
    {
        return self.deviceTypes.count + 1;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.selectedDeviceTableView)
    {
        if(section == 0)
        {
            return 0;
        }
        return 1;
    }
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
            cell.timeLabel.text =@"节约能耗，从我做起";
            cell.totalLabel.text = [NSString stringWithFormat:@"超出上月的能耗:%@%%",dic[@"overEngry"]];
            
        }else{
            NSString *ename = dic[@"ename"];
            int hour = [dic[@"hour"] intValue];
            int times = [dic[@"times"] intValue];
            
            NSString *energy = dic[@"energy"];
            cell.totalLabel.text = [NSString stringWithFormat:@"总计:%@KWH",energy]; ;
            
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
        }
        if(indexPath.section != 0)
        {
            [self setButtnonInCell:cell deviceIDs:self.deviceIDs[indexPath.section - 1]];
        }
        
        return cell;

    }


 
}
-(void)setButtnonInCell:(UITableViewCell *)cell deviceIDs:(NSArray *)deviceIDs;
{
    CGFloat viewW = CellItemViewWidth;
    CGFloat viewH = CellItemViewHeight;
    CGFloat startX = 10;
    CGFloat marginX = (cell.frame.size.width - CellItemCol * viewW - 2 * startX)/(CellItemCol-1);
    CGFloat marginY = 10;
    int count = (int)deviceIDs.count;
    
    int viewCount = (int)cell.contentView.subviews.count;
    
    for(int i = 0; i < count; i++)
    {
        int row = i / CellItemCol;
        int loc = i % CellItemCol;
        
        CGFloat orignX = startX +(marginX + viewW) * loc;
        CGFloat orignY = marginY +(marginY + viewH) * row;
        
        UIView *view = nil;
        UIImageView *img = nil;
        UIButton *btn = nil;
        
        if ( i < viewCount )
        {
            view = cell.contentView.subviews[i];
            
            img = view.subviews[0];
            
            btn = view.subviews[1];
        }
        else
        {
            view = [[UIView alloc] init];
            view.userInteractionEnabled = YES;
            [cell.contentView addSubview:view];
            
            img = [[UIImageView alloc]initWithFrame:CGRectMake(0,10, 30, 30)];
            [view addSubview:img];
            
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(goToEngerOfDevice:) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:btn];
        }
        
        view.frame = CGRectMake(orignX, orignY, viewW, viewH);
        
        img.image = [UIImage imageNamed:@"logo"];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.textAlignment =NSTextAlignmentLeft;
        btn.frame = CGRectMake(30, 10, 120, 30);
        NSString *title = [SQLManager deviceNameByDeviceID:[deviceIDs[i] intValue]];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.tag = [deviceIDs[i] intValue];
        
        view.hidden = NO;
    }
    
    for (int i = count; i < cell.contentView.subviews.count; i++) {
        UIView *view = cell.contentView.subviews[i];
        view.hidden = YES;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == self.selectedDeviceTableView)
    {
        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake(0, 0, self.selectedDeviceTableView.frame.size.width, 44);
        view.backgroundColor = [UIColor lightGrayColor];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, view.bounds.size.width, view.bounds.size.height)];
        if(section == 0)
        {
            [button setTitle:@"全部设备" forState:UIControlStateNormal];
        }else {
            [button setTitle:self.deviceType[section -1] forState:UIControlStateNormal];
            

        }
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.tag = section;
        [button addTarget:self action:@selector(handleHeaderButton:) forControlEvents:UIControlEventTouchUpInside];

        [view addSubview:button];
        return view;
    }
    return nil;
   
}
-(void)handleHeaderButton:(UIButton *)btn
{
    NSMutableArray *eIDs = [NSMutableArray array];
    
    if (btn.tag == 0) {
        for(int i = 0; i < self.selectedDeviceTableView.numberOfSections - 2; i++) {
            [eIDs addObjectsFromArray:self.deviceIDs[i]];
        }
    } else {
        eIDs = self.deviceIDs[btn.tag - 1];
    }
    
    self.engerOfDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EnergyOfDeviceController"];
    
    self.engerOfDeviceVC.eIds = eIDs;
    [self.navigationController pushViewController:self.engerOfDeviceVC animated:NO];
}
-(void)goToEngerOfDevice:(UIButton *)btn
{
    self.engerOfDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EnergyOfDeviceController"];
    
    NSString *eid = [NSString stringWithFormat:@"%d",(int)btn.tag];
    
    self.engerOfDeviceVC.eIds = @[eid];
    [self.navigationController pushViewController:self.engerOfDeviceVC animated:NO];
    
}

- (CGFloat)tableViewCellHeight:(NSInteger)itemCount
{
    return CellItemMarginY + (CellItemMarginY + CellItemViewHeight) * ( (itemCount + CellItemCol - 1) / CellItemCol );
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.selectedDeviceTableView)
    {
        //NSArray *b = A[indexPath.section];
        //return [self tableViewCellHeight:b.count]
        if(indexPath.section == 0)
        {
            return 44;
        }
        return [self tableViewCellHeight:[self.deviceIDs[indexPath.section - 1] count]];

    }
    return 44;
    
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if(tableView == self.selectedDeviceTableView)
//    {
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

- (IBAction)clickEditBtn:(id)sender {
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    // 允许编辑
    self.tableView.editing = YES;
    
    self.footView.hidden = NO;
    self.isEditing = YES;
    [self.tableView reloadData];
}

- (IBAction)clickCancleBtn:(id)sender {
    // 允许多个编辑
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    // 允许编辑
    self.tableView.editing = NO;
    //  self.tableView.tableFooterView = nil;
    self.footView.hidden = YES;
    self.isEditing = NO;
    [self.tableView reloadData];

}

- (IBAction)clickSureBtn:(id)sender {
    //放置要删除的对象
    NSMutableArray *deleteArray = [NSMutableArray array];
//    NSMutableArray *deletedTime = [NSMutableArray array];
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        //[deleteArray addObject:self.Mydefaults[indexPath.row]];
        [deleteArray addObject:self.enegers[indexPath.row]];
//        [deletedTime addObject:self.times[indexPath.row]];
    }
    // 先删除数据源
    [self.enegers removeObjectsInArray:deleteArray];
//    [self.times removeObjectsInArray:deletedTime];
    
    [self clickCancleBtn:nil];

}

- (IBAction)selectedDevice:(id)sender {
    self.selectedDeviceTableView.hidden = !self.selectedDeviceTableView.hidden;
}

-(void)removeAllSubViewFromMyEnergyViewController
{
    [self.engerOfDeviceVC.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
