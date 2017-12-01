//
//  IpadDeviceTypeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadDeviceTypeVC.h"
#import "IpadDeviceTypeCell.h"
#import "SQLManager.h"
#import "AddDeviceCell.h"
#import "AddIpadSceneVC.h"

@interface IpadDeviceTypeVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic,strong) NSMutableArray * SubTypeNameArr;
@property (nonatomic,strong) NSArray * SubTypeIconeImage;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IpadDeviceTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMenu];
    self.roomList = [SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID];
    [self setupNaviBar];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddDeviceCell" bundle:nil] forCellReuseIdentifier:@"AddDeviceCell"];//添加设备的cell
    self.tableView.scrollEnabled =NO; //设置tableview 不能滚动
}

- (void)initMenu {
    self.SubTypeNameArr = [NSMutableArray new];
    NSArray *devicesIDs = [SQLManager getDeviceIDsBySeneId:self.sceneID];
    [devicesIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSNumber *deviceID = obj;
        NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[deviceID intValue]];
        if (deviceTypeName.length >0) {
            [self.SubTypeNameArr addObject:deviceTypeName];
        }
    }];
    
    //菜单项去重
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    for(NSString *str in self.SubTypeNameArr)
    {
        [dic setValue:str forKey:str];
    }
    
    [self.SubTypeNameArr removeAllObjects];
    if ([dic allKeys].count >0) {
        [self.SubTypeNameArr addObjectsFromArray:[dic allKeys]];
    }
    
    //排序(灯排在第一个)
    [self.SubTypeNameArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        NSString *deviceTypeName = obj;
        if ([deviceTypeName isEqualToString:@"灯光"]) {
            [self.SubTypeNameArr removeObject:obj];
            [self.SubTypeNameArr insertObject:@"灯光" atIndex:0];
            *stop = YES;
        }
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.SubTypeNameArr.count >0) {
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        if ([self.delegate respondsToSelector:@selector(IpadDeviceType:selected:typeName:)]) {
            
            [self.delegate IpadDeviceType:self selected:0 typeName:self.SubTypeNameArr[0]];
        }
    }
}

- (void)setupNaviBar {
    
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"backBtn" imgHighlight:@"backBtn" target:self action:@selector(leftBtnClicked:)];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)leftBtnClicked:(UIButton *)leftBtn
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        
    }];
}
-(void)rightBtnClicked:(UIButton *)rightBtn
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        //    return self.roomList.count;
        return self.SubTypeNameArr.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
         return 175;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    
    return view;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        IpadDeviceTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.SubTypeNameLabel.text = self.SubTypeNameArr[indexPath.row];
        NSString *iconImage = @"";
        if ([cell.SubTypeNameLabel.text isEqualToString:@"灯光"]) {
            iconImage = @"icon_light_nol";
        }else if ([cell.SubTypeNameLabel.text isEqualToString:@"影音"]) {
            iconImage = @"icon_vdo_nol";
        }else if ([cell.SubTypeNameLabel.text isEqualToString:@"环境"]) {
            iconImage = @"icon_airconditioner_nol";
        }else if ([cell.SubTypeNameLabel.text isEqualToString:@"窗帘"]) {
            iconImage = @"icon_windowcurtains_nol";
        }else if ([cell.SubTypeNameLabel.text isEqualToString:@"智能单品"]) {
            iconImage = @"icon_Intelligence_nol";
        }else if ([cell.SubTypeNameLabel.text isEqualToString:@"安防"]) {
            iconImage = @"ipad-icon_safe_nol";
        }
        
        cell.SubTypeIconeImage.image = [UIImage imageNamed:iconImage];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_nol"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_prd"]];
        return cell;
    }
   
    AddDeviceCell * addDeviceCell = [tableView dequeueReusableCellWithIdentifier:@"AddDeviceCell" forIndexPath:indexPath];
    addDeviceCell.backgroundColor = [UIColor clearColor];
    addDeviceCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_nol"]];
    addDeviceCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_prd"]];
   
    return addDeviceCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.delegate respondsToSelector:@selector(IpadDeviceType:selected:typeName:)]) {
            
            [self.delegate IpadDeviceType:self selected:indexPath.row typeName:self.SubTypeNameArr[indexPath.row]];
        }
    }
    if (indexPath.section == 1) { //给场景添加设备
        NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
        if (userType == 2) { //客人不允许给场景添加设备
            [MBProgressHUD showError:@"非主人不允许给场景添加设备"];
            return;
        }
        AddIpadSceneVC * AddIpadVC = [[AddIpadSceneVC alloc] init];
        AddIpadVC.roomID = self.roomID;
        AddIpadVC.sceneID = self.sceneID;
        
        [self.navigationController pushViewController:AddIpadVC animated:YES];
    }
   
}


@end
