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

@interface IphoneNewAddSceneVC ()<UITableViewDelegate,UITableViewDataSource,IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray * deviceArr;
@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic,assign) int roomID;

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
          [self reachNotification];
}
-(void)setUpRoomView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.roomList) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    self.roomView.dataArray = roomNames;
    
    self.roomView.delegate = self;
    
    [self.roomView setSelectButton:0];
    
    [self iphoneRoomView:self.roomView didSelectButton:0];
}
- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    Room *room = self.roomList[index];
    self.scenes = [SQLManager getScensByRoomId:room.rId];
  
    
}
- (void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTypeNotification:) name:@"subType" object:nil];
}
- (void)subTypeNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    
    self.roomID = [dict[@"subType"] intValue];
    
    self.scenes = [SQLManager getScensByRoomId:self.roomID];
    
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
    return _deviceArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
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
