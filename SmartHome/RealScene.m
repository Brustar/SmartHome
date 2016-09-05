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
#import "PackManager.h"
#import "SocketManager.h"

@interface RealScene ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *roomTable;

//温度
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
//湿度
@property (weak, nonatomic) IBOutlet UILabel *wetLabel;
//pm2.5
@property (weak, nonatomic) IBOutlet UILabel *pmLabel;
//噪音
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;


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
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (proto.masterID != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state==0x7A) {
            self.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.wetLabel.text = valueString;
        }
        if (proto.action.state==0x7F) {
            NSString *valueString = [NSString stringWithFormat:@"%d ug/m",proto.action.RValue];
            self.pmLabel.text = valueString;
        }
        if (proto.action.state==0x7E) {
            NSString *valueString = [NSString stringWithFormat:@"%d db",proto.action.RValue];
            self.noiseLabel.text = valueString;
        }
    }
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
