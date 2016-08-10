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
@property (nonatomic,strong) NSArray *subLigths;
@property (nonatomic,strong) NSArray *subMedia;
@property (nonatomic,strong) NSArray *subProtect;
@property (nonatomic,strong) NSArray *subEnvironmetn;
@property (nonatomic,strong) NSArray *devicesInfo;
@end

@implementation MyEnergyViewController

-(NSMutableArray *)energys
{
    if(!_energys)
    {
        _energys = [NSMutableArray array];
        [_energys addObjectsFromArray:@[@"123",@"222",@"333"]];
    }
    return _energys;
}

-(NSMutableArray *)times
{
    if(!_times)
    {
        _times = [NSMutableArray array];
        [_times addObjectsFromArray:@[@"2016-8-9",@"2016-5-3",@"2016-7-9"]];
    }
    return _times;
}
-(NSArray *)devicesInfo{
    if(!_devicesInfo)
    {
        _devicesInfo = [DeviceManager getAllDevicesInfo];
    }
    return _devicesInfo;
}

-(void)getEnger{
    NSString *url = [NSString stringWithFormat:@"%@GetEnergyMessage.aspx",[IOManager httpAddr]];
    NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"Date":@"2016-07-11",@"EquipmentIdList":@"15"};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的能耗";
    
    self.footView.hidden = YES;
    [self setNavi];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footView;
    self.selectedDeviceTableView.tableFooterView = [UIView new];
    
    self.deviceType = @[@"全部设备",@"照明设备",@"影音设备",@"安防设备",@"环境设备"];
    
    self.subLigths = @[@"1",@"3",@"2",@"4"];
    self.subMedia = [DetailList getDeviceForModel:@"影音"];
    self.subProtect = [DetailList getDeviceForModel:@"安防"];
    self.subEnvironmetn = [DetailList getDeviceForModel:@"环境"];
    self.selectedDeviceTableView.hidden = YES;
    
    [self getEnger];
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
        return self.deviceType.count;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.selectedDeviceTableView)
    {
        return 1;
    }
    return self.energys.count;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        MyEnergyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyEnergyCell" forIndexPath:indexPath];
        cell.timeLabel.text = self.energys[indexPath.row];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            if(indexPath.section == 0)
            {
                NSArray *arrry = @[@"全部设备"];
                [self setButtnonInCell:cell andSubDevie:arrry];
            }else if(indexPath.section == 1)
            {
                [self setButtnonInCell:cell andSubDevie:self.subLigths];
            }else if(indexPath.section == 2)
            {
                [self setButtnonInCell:cell andSubDevie:self.subMedia];
            }else if(indexPath.section == 3)
            {
                [self setButtnonInCell:cell andSubDevie:self.subProtect];
            }else
            {
                [self setButtnonInCell:cell andSubDevie:self.subEnvironmetn];
            }
        }
        
        return cell;
    }
    

 
}
-(void)setButtnonInCell:(UITableViewCell *)cell andSubDevie:(NSArray *)devices;
{
    CGFloat viewW = CellItemViewWidth;
    CGFloat viewH = CellItemViewHeight;
    CGFloat startX = 10;
    CGFloat marginX = (cell.frame.size.width - CellItemCol * viewW - 2 * startX)/(CellItemCol-1);
    CGFloat marginY = 10;
    int count = (int)devices.count;
    for(int i = 0; i < count; i++)
    {
        int row = i / CellItemCol;
        int loc = i % CellItemCol;
        
        CGFloat orignX = startX +(marginX + viewW) * loc;
        CGFloat orignY = marginY +(marginY + viewH) * row;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(orignX, orignY, viewW, viewH)];
        view.userInteractionEnabled = YES;
        //view.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:view];
        
        //创建View的子视图
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0,10, 30, 30)];
        img.image = [UIImage imageNamed:@"placeholder"];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [view addSubview:img];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        btn.frame = CGRectMake(30, 10, 80, 30);
        [btn setTitle:@"1eddeee" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goToEngerOfDevice:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:btn];
    }
    
}

-(void)goToEngerOfDevice:(UIButton *)btn
{
    self.engerOfDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EnergyOfDeviceController"];
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
        //        NSArray *b = A[indexPath.section];
        //        return [self tableViewCellHeight:b.count]
        
        switch (indexPath.section) {
            case 0:
                return [self tableViewCellHeight:1];
                
            case 1:
                return [self tableViewCellHeight:self.subLigths.count];
                
            case 2:
                return [self tableViewCellHeight:self.subMedia.count];
                
            case 3:
                return [self tableViewCellHeight:self.subProtect.count];
                
            case 4:
                return [self tableViewCellHeight:self.subEnvironmetn.count];
                
            default:
                break;
        }
        
    }
    return 44;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.selectedDeviceTableView)
    {
        if(section == 0)
        {
            return nil;
        }else {
            return self.deviceType[section];

        }
        
    }
    
    return nil;
}

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
    NSMutableArray *deletedTime = [NSMutableArray array];
    // 要删除的row
    NSArray *selectedArray = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedArray) {
        //[deleteArray addObject:self.Mydefaults[indexPath.row]];
        [deleteArray addObject:self.energys[indexPath.row]];
        [deletedTime addObject:self.times[indexPath.row]];
    }
    // 先删除数据源
    [self.energys removeObjectsInArray:deleteArray];
    [self.times removeObjectsInArray:deletedTime];
    
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
