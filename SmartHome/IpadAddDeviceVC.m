//
//  IpadAddDeviceVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//SplitViewController 左边视图控制器选择展示

#import "IpadAddDeviceVC.h"
#import "IpadDeviceTypeCell.h"
#import "SQLManager.h"
#import "IphoneSaveNewSceneController.h"

@interface IpadAddDeviceVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic,strong) NSArray * SubTypeNameArr;
@property (nonatomic,strong) NSArray * SubTypeIconeImage;
@property (nonatomic, readonly) UIButton *naviRightBtn;

@end

@implementation IpadAddDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.SubTypeNameArr = @[@"灯光",@"影音",@"环境",@"窗帘",@"智能单品",@"安防"];
    self.SubTypeIconeImage = @[@"icon_light_nol",@"icon_vdo_nol",@"icon_airconditioner_nol",@"icon_windowcurtains_nol",@"icon_Intelligence_nol",@"ipad-icon_safe_nol"];
    self.roomList = [SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID];
    self.tableView.tableFooterView = [UIView new];
    [self setupNaviBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
      [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    if ([self.delegate respondsToSelector:@selector(IpadAddDeviceVC:selected:)]) {
        
        [self.delegate IpadAddDeviceVC:self selected:0];
    }

}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    return self.roomList.count;
    return self.SubTypeNameArr.count;
}

- (void)setupNaviBar {
    
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    
    [self setNaviBarRightBtn:_naviRightBtn];

}

-(void)rightBtnClicked:(UIButton *)rightBtn
{
        UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        IphoneSaveNewSceneController * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
        // [self presentViewController:iphoneSaveNewScene animated:YES completion:nil];
        iphoneSaveNewScene.roomId = self.roomID;
        [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
        //[self performSegueWithIdentifier:@"iphoneAddNewScene" sender:self];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IpadDeviceTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.SubTypeNameLabel.text = self.SubTypeNameArr[indexPath.row];
    cell.SubTypeIconeImage.image = [UIImage imageNamed:self.SubTypeIconeImage[indexPath.row]];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_nol"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-btn_choose_prd"]];
  
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.delegate respondsToSelector:@selector(IpadAddDeviceVC:selected:)]) {
        
        [self.delegate IpadAddDeviceVC:self selected:indexPath.row];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 64;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
