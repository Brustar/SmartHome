//
//  RealScene.m
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RealScene.h"
#import "RoomManager.h"
#import "Room.h"

@interface RealScene ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *roomTable;
@property (nonatomic,strong) NSArray *rooms;
@end

@implementation RealScene

-(NSArray *)rooms
{
    if(!_rooms)
    {
        _rooms = [RoomManager getAllRoomsInfo];
    }
    return _rooms;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    //self.realimg=[[TouchImage alloc] initWithFrame:CGRectMake(100, 40, 625, 500)];
    self.realimg.image =[UIImage imageNamed:@"real.png"];
    self.realimg.userInteractionEnabled=YES;
    self.realimg.viewFrom=REAL_IMAGE;
    [self.view addSubview:self.realimg];
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
    
    Room *room = self.rooms[indexPath.row];
    cell.textLabel.text = room.rName;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
