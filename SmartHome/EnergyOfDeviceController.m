//
//  EnergyOfDeviceController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "EnergyOfDeviceController.h"
#import "EnegryOfDeviceCell.h"
#import "DeviceManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface EnergyOfDeviceController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
// 所有设备名称
@property (nonatomic, strong) NSMutableArray *deviceNames;
//所有设备能耗
@property (weak, nonatomic) IBOutlet UIButton *fisrtTimeBtn;
@property (nonatomic, strong) NSMutableArray *deviceEnergys;
@property (nonatomic,strong) NSString *eIDStr;
@property (nonatomic,strong) UIButton *selectedTimeBtn;
@end

@implementation EnergyOfDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.selectedTimeBtn = self.fisrtTimeBtn;
    self.selectedTimeBtn.selected = YES;
    [self.selectedTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.tableHeaderView = self.headView;
    
    NSMutableString *eIDStr = [NSMutableString string];
    for (NSString *eid in self.eIds) {
        
        if (eIDStr.length > 0) {
            [eIDStr appendString:@","];
        }
        [eIDStr appendString:eid];
    }
    self.eIDStr = [eIDStr copy];
    [self getCurrentDateEnger];

}
-(void)getCurrentDateEnger
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yy-MM-dd hh:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *currentStr = [dateformatter stringFromDate:currentDate];
    [self getEnger:currentStr];
    
}

-(void)getEnger:(NSString *)timeStr{
    NSString *url = [NSString stringWithFormat:@"%@GetEnergyMessage.aspx",[IOManager httpAddr]];
    
    NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"Date":timeStr,@"EquipmentIdList":self.eIDStr};
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
            NSArray *devices = responseObject[@"messageInfo"];
            
            self.deviceNames = [NSMutableArray array];
            self.deviceEnergys = [NSMutableArray array];
            
            for (NSDictionary *dict in devices) {
                NSString *name = dict[@"eName"];
                NSString *energy = [NSString stringWithFormat:@"%d",[dict[@"energy"] intValue]];
                
                [self.deviceNames addObject:name];
                [self.deviceEnergys addObject:energy];
                
            }
            
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eIds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnegryOfDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnegryOfDeviceCell" forIndexPath:indexPath];
    
    cell.deviceName.text = self.deviceNames[indexPath.row];
    cell.energyOfDevice.text = [NSString stringWithFormat:@"%@KWH", self.deviceEnergys[indexPath.row]];
    
    
    return cell;

}
- (IBAction)selectedTime:(UIButton *)sender {
    self.selectedTimeBtn.selected = NO;
    
    sender.titleLabel.textColor = [UIColor blackColor];
    sender.selected = YES;
    self.selectedTimeBtn = sender;
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yy-MM-dd hh:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *timeStr;
    switch (sender.tag) {
            
        case 0:
            
            timeStr = [dateformatter stringFromDate:currentDate];
            break;
        case 1:
            timeStr = [dateformatter stringFromDate:[currentDate dateByAddingTimeInterval:-(60*60*24*7)]];
            break;
        case 2:
            timeStr = [dateformatter stringFromDate:[currentDate dateByAddingTimeInterval:-(60*60*24*30)]];
            break;
        default:
            timeStr = [dateformatter stringFromDate:[currentDate dateByAddingTimeInterval:-(60*60*24*90)]];
            break;
    }
    [self getEnger:timeStr];
}

- (IBAction)clickRetunBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
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
