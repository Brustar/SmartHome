//
//  IphoneNewAddSceneVC.m
//  SmartHome
//
//  Created by zhaona on 2017/4/6.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneNewAddSceneVC.h"
#import "IphoneRoomView.h"
#import "Room.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"
#import "IphoneNewAddSceneCell.h"

@interface IphoneNewAddSceneVC ()<UITableViewDelegate,UITableViewDataSource,IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray * deviceArr;
@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,strong) NSArray *devices;


@end

@implementation IphoneNewAddSceneVC
-(NSArray *)deviceArr
{
    if (_deviceArr == nil) {
        _deviceArr = [NSArray array];
    }
    return _deviceArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

      self.roomList = [SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID];
      [self setUpRoomView];
//          [self reachNotification];
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    
    
    
}
-(void)setUpRoomView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (NSString *subTypeStr in self.roomList) {
        if([subTypeStr isEqualToString:@"照明"]){
            [roomNames addObject:subTypeStr];
        }if ([subTypeStr isEqualToString:@"影音"]) {
            [roomNames addObject:subTypeStr];
        }if([subTypeStr isEqualToString:@"环境"]){
            [roomNames addObject:subTypeStr];
        }if([subTypeStr isEqualToString:@"安防"]){
            [roomNames addObject:subTypeStr];
        }if([subTypeStr isEqualToString:@"智能单品"]){
            [roomNames addObject:subTypeStr];
        }
    }
    self.roomView.dataArray = roomNames;
    
    self.roomView.delegate = self;
    
    [self.roomView setSelectButton:0];
    
    [self iphoneRoomView:self.roomView didSelectButton:0];
}
- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    if (self.roomList.count == 0) {
        [MBProgressHUD showError:@"该房间没有设备"];
    }else{
        NSString * selectSubTypeStr = self.roomList[index];
        //    getDeviceTypeNameWithSubTypeName:(NSString *)subTypeName
        self.devices = [SQLManager  getDeviceTypeNameWithSubTypeName:selectSubTypeStr];
        
        [self.tableView reloadData];
    }
    
}
- (void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTypeNotification:) name:@"subType" object:nil];
}
- (void)subTypeNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    
    self.roomID = [dict[@"subType"] intValue];
    
    self.devices = [SQLManager getScensByRoomId:self.roomID];
    
    //    [self setUpSceneButton];
    //    [self judgeScensCount:self.scenes];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma UITableViewDelegate的代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devices.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IphoneNewAddSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
   
     cell.backgroundColor = [UIColor clearColor];
     cell.DeviceNameLabel.text = self.devices[indexPath.row];
    return cell;
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
