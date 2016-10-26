//
//  IphoneRoomListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneRoomListController.h"
#import "SQLManager.h"
#import "Room.h"

@interface IphoneRoomListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *rooms;

@end

@implementation IphoneRoomListController


-(NSArray *)rooms
{
    if(!_rooms)
    {
        NSArray *roomList = [SQLManager getAllRoomsInfo];
        NSMutableArray *roomNames = [NSMutableArray array];
        
        for (Room *room in roomList) {
            NSString *roomName = room.rName;
            [roomNames addObject:roomName];
        }
        _rooms = [roomNames copy];
        
    }
    return _rooms;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    cell.textLabel.text = self.rooms[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate iphoneRoomListController:self withRoomName:self.rooms[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
