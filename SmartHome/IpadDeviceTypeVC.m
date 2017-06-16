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
@property (nonatomic,strong) NSArray * SubTypeNameArr;
@property (nonatomic,strong) NSArray * SubTypeIconeImage;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IpadDeviceTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.SubTypeNameArr = @[@"灯光",@"影音",@"环境",@"窗帘",@"智能单品",@"安防"];
    self.SubTypeIconeImage = @[@"icon_light_nol",@"icon_vdo_nol",@"icon_airconditioner_nol",@"icon_windowcurtains_nol",@"icon_Intelligence_nol",@"ipad-icon_safe_nol"];
      self.roomList = [SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID];
      [self setupNaviBar];
     [self.tableView registerNib:[UINib nibWithNibName:@"AddDeviceCell" bundle:nil] forCellReuseIdentifier:@"AddDeviceCell"];//添加设备的cell
     self.tableView.scrollEnabled =NO; //设置tableview 不能滚动

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    
    if ([self.delegate respondsToSelector:@selector(IpadDeviceType:selected:)]) {
        
        [self.delegate IpadDeviceType:self selected:1];
    }
    if (self.DevicesArr.count == 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        if ([self.delegate respondsToSelector:@selector(IpadDeviceType:selected:)]) {
            
            [self.delegate IpadDeviceType:self selected:0];
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
        cell.SubTypeIconeImage.image = [UIImage imageNamed:self.SubTypeIconeImage[indexPath.row]];
        
        return cell;
    }
   
    AddDeviceCell * addDeviceCell = [tableView dequeueReusableCellWithIdentifier:@"AddDeviceCell" forIndexPath:indexPath];
    addDeviceCell.backgroundColor = [UIColor clearColor];
   
    return addDeviceCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.delegate respondsToSelector:@selector(IpadDeviceType:selected:)]) {
            
            [self.delegate IpadDeviceType:self selected:indexPath.row];
        }
    }
    if (indexPath.section == 1) {
       
        AddIpadSceneVC * AddIpadVC = [[AddIpadSceneVC alloc] init];
        AddIpadVC.roomID = self.roomID;
        AddIpadVC.sceneID = self.sceneID;
        
        [self.navigationController pushViewController:AddIpadVC animated:YES];
    }
   
}


@end
