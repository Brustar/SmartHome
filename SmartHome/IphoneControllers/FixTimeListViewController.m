//
//  FixTimeListViewController.m
//  SmartHome
//
//  Created by zhaona on 2016/12/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FixTimeListViewController.h"
#import "SQLManager.h"
#import "Scene.h"
#import "FixTimeListCell.h"

@interface FixTimeListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * deviceArr;
@property (nonatomic,strong) NSMutableArray * sceneArr;
@property (nonatomic,strong) NSArray * AllsceneArr;
@property (nonatomic,assign) NSInteger sceneID;
@property (nonatomic,strong) NSMutableArray * startTimeArr;
@property (nonatomic,strong) NSMutableArray * endTimeArr;
@property (nonatomic,strong) NSString * repetitionStr;

@end

@implementation FixTimeListViewController
-(NSMutableArray *)startTimeArr
{
    if (!_startTimeArr) {
        _startTimeArr =[NSMutableArray array];
    }
    
    return _startTimeArr;

}

-(NSMutableArray *)endTimeArr
{
    if (!_endTimeArr) {
        _endTimeArr = [NSMutableArray array];
    }

    return _endTimeArr;
}

-(NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    
    return _deviceArr;
}

-(NSMutableArray *)sceneArr
{
    if (!_sceneArr) {
        _sceneArr = [NSMutableArray array];
    }

    return _sceneArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.AllsceneArr = [SQLManager getAllScene];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma UITableView-Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"设备";
    }
    return @"场景";
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.deviceArr.count;
    }
    
    return self.AllsceneArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    FixTimeListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FixTimeListCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Scene * scene = self.AllsceneArr[indexPath.row];
    cell.sceneNameLabel.text = [NSString stringWithFormat:@"%@-%@",[SQLManager getRoomNameByRoomID:scene.roomID],scene.sceneName];
    for (NSDictionary * dict in scene.schedules) {
        NSString * startTime = dict[@"startTime"];
        NSString * endTime =   dict[@"endTime"];
        NSArray * weekDayArr = dict[@"weekDays"];
        self.repetitionStr = [NSString string];
        self.repetitionStr = [weekDayArr componentsJoinedByString:@"、"];
        [self.startTimeArr addObject:startTime];
        [self.endTimeArr addObject:endTime];
    }
    if (scene.schedules.count ==0) {
        cell.sceneTimeLabel.text =@"暂无定时信息";
        cell.repetitionLabel.text = @"暂无重复日期";
    }else{
        cell.sceneTimeLabel.text = [NSString stringWithFormat:@"%@-%@",self.startTimeArr[indexPath.row],self.endTimeArr[indexPath.row]];
        cell.repetitionLabel.text = self.repetitionStr;
    }
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
