//
//  IPadMenuController.m
//  SmartHome
//
//  Created by Brustar on 2017/5/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IPadMenuController.h"
#import "SQLManager.h"
#import "LeftMenuCell.h"
#import "LightController.h"

@interface IPadMenuController ()

@end

static NSString *const leftMenuCell = @"leftMenuCell";

@implementation IPadMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"frm_left_nol"]]];
    
    self.types = [SQLManager typeName:self.typeID byRoom:self.roomID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *cellNib = [UINib nibWithNibName:@"LeftMenuCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:leftMenuCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *temp = [NSMutableArray new];
    NSArray *ts = [SQLManager typeName:self.typeID byRoom:self.roomID];
    Device *device = [self.types objectAtIndex:indexPath.row];
    NSString *typeid = [NSString stringWithFormat:@"0%ld", device.hTypeId];
    if (device.hTypeId >0 && device.hTypeId<10) {
        [temp addObjectsFromArray:ts];
        NSArray *arr = [SQLManager devicesWithCatalogID:typeid room:self.roomID];
        for (id obj in arr) {
            [temp insertObject:obj atIndex:device.rID];
        }
        self.types = temp;
        [self.tableView reloadData];
    }else if(device.hTypeId>=10){
        //多媒体或智能单品
        [self showDetailViewController:[DeviceInfo calcController:device.hTypeId] sender:self];
    }
    
    if (device.eID>0) {
        //split delegate
        LightController *control = (LightController *)[DeviceInfo calcController:light];
        control.deviceid = [NSString stringWithFormat:@"%d", device.eID];
        
        [self showDetailViewController:control sender:self];
        [control visibleUI:device];
    }
}

//设置表头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:leftMenuCell forIndexPath:indexPath];
    
    if (cell) {
        Device *device = [self.types objectAtIndex:indexPath.row];
        cell.lbl.text = device.typeName?device.typeName:device.name;
        if (device.typeName) {
            cell.lbl.textColor = [UIColor whiteColor];
            cell.cellBG.image = [UIImage imageNamed:@"left_menu_normal"];
        }else{
            cell.lbl.textColor = [UIColor grayColor];
            cell.cellBG.image = [UIImage imageNamed:@"left_sub_normal"];
        }
    }
    
    return cell;
}

@end
