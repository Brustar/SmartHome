//
//  DeviceTimerSettingViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceTimerSettingViewController.h"

@interface DeviceTimerSettingViewController ()

@end

@implementation DeviceTimerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    [self setNaviBarTitle:@"定时设置"];
    
    _timerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    _timerTableView.dataSource = self;
    _timerTableView.delegate = self;
    _timerTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _timerTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _timerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.timerTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//灯光
    [self.timerTableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.timerTableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.timerTableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    [self.timerTableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.timerTableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.timerTableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//投影仪ScreenTableViewCell
    [self.timerTableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.timerTableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    [self.timerTableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    
    [self.view addSubview:_timerTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        return 0.5f;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        
        return footer;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.device.hTypeId == 12 || self.device.hTypeId == 13) {
            return 150.0f;
        }else if (self.device.hTypeId == 11 || self.device.hTypeId == 16 || self.device.subTypeId == 5) {
            return 50.0f;
        }else {
            return 100.0f;
        }
    }
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.device.subTypeId == 1) { //灯光
            NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.AddLightBtn.hidden = YES;
            cell.LightConstraint.constant = 10;
            cell.NewLightNameLabel.text = self.device.name;
            cell.NewLightSlider.continuous = NO;
            cell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            return cell;
        }else if (self.device.subTypeId == 7) { //窗帘
            CurtainTableViewCell *curtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
            curtainCell.backgroundColor =[UIColor clearColor];
            curtainCell.selectionStyle = UITableViewCellSelectionStyleNone;
            curtainCell.AddcurtainBtn.hidden = YES;
            curtainCell.curtainContraint.constant = 10;
            curtainCell.roomID = (int)self.roomID;
            curtainCell.label.text = self.device.name;
            curtainCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            
            return curtainCell;
        }else if (self.device.hTypeId == 31) {  //空调
            AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
            aireCell.backgroundColor = [UIColor clearColor];
            aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
            aireCell.AddAireBtn.hidden = YES;
            aireCell.AireConstraint.constant = 10;
            aireCell.roomID = (int)self.roomID;
            aireCell.AireNameLabel.text = self.device.name;
            aireCell.deviceid = [NSString stringWithFormat:@"%d", self.device.eID];
            return aireCell;
        }else if (self.device.hTypeId == 14) { //背景音乐
            BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
            BjMusicCell.backgroundColor = [UIColor clearColor];
            BjMusicCell.selectionStyle = UITableViewCellSelectionStyleNone;
            BjMusicCell.AddBjmusicBtn.hidden = YES;
            BjMusicCell.BJmusicConstraint.constant = 10;
            BjMusicCell.BjMusicNameLb.text = self.device.name;
            return BjMusicCell;
        }else if (self.device.hTypeId == 13) { //DVD
            DVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
            dvdCell.backgroundColor =[UIColor clearColor];
            dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dvdCell.AddDvdBtn.hidden = YES;
            dvdCell.DVDConstraint.constant = 10;
            dvdCell.DVDNameLabel.text = self.device.name;
            return dvdCell;
        }else if (self.device.hTypeId == 17) { //幕布
            ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
            ScreenCell.backgroundColor =[UIColor clearColor];
            ScreenCell.selectionStyle = UITableViewCellSelectionStyleNone;
            ScreenCell.AddScreenCurtainBtn.hidden = YES;
            ScreenCell.ScreenCurtainConstraint.constant = 10;
            ScreenCell.ScreenCurtainLabel.text = self.device.name;
            return ScreenCell;
        }else if (self.device.hTypeId == 16) { //投影仪(只有开关)
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor = [UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }else if (self.device.hTypeId == 11) { //机顶盒
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }else if (self.device.hTypeId == 12) { //网络电视
            TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
            tvCell.backgroundColor =[UIColor clearColor];
            tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvCell.AddTvDeviceBtn.hidden = YES;
            tvCell.TVConstraint.constant = 10;
            tvCell.TVNameLabel.text = self.device.name;
            return tvCell;
        }else if (self.device.hTypeId == 18) { //功放
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }else { //影音其他类型（如：FM）
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = self.device.name;
            return otherCell;
        }
        
    }else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"应用时段";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if (indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"立即启动";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *activeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 23)];
        [activeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
        [activeBtn addTarget:self action:@selector(activeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = activeBtn;
        
        return cell;
    }
    
    return nil;
}

- (void)activeBtnClicked:(UIButton *)btn {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
}

@end
