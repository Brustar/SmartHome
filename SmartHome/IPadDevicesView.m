//
//  IPadDevicesView.m
//  SmartHome
//
//  Created by Brustar on 2017/6/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IPadDevicesView.h"
#import "SQLManager.h"
#import "LeftMenuCell.h"


static NSString *const leftMenuCell = @"leftMenuCell";
@implementation IPadDevicesView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2+10);
    }
    return self;
}

-(void)initData
{
    self.menus = [SQLManager allTypeinRoom:self.roomID];
    self.menu.dataSource = self.content.dataSource = self;
    self.menu.delegate = self.content.delegate = self;
    
    self.devices = [SQLManager deviceIdsByRoomId:self.roomID];
    [self.menu setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad-frm_left_nol"]]];
    self.menu.separatorStyle = self.content.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *cellNib = [UINib nibWithNibName:@"LeftMenuCell" bundle:nil];
    [self.menu registerNib:cellNib forCellReuseIdentifier:leftMenuCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1) {
        return self.devices.count;
    }
    return self.menus.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:leftMenuCell forIndexPath:indexPath];
    if (tableView.tag == 1) {
        
    }else{
        Device *device = [self.menus objectAtIndex:indexPath.row];
        cell.lbl.text = device.subTypeName;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
