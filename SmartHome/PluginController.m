//
//  PluginController.m
//  SmartHome
//
//  Created by Brustar on 16/8/3.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PluginController.h"
#import "SocketManager.h"
#import "AsyncUdpSocket.h"
#import "PackManager.h"
#import "PluginCell.h"

@interface PluginController ()

@end

@implementation PluginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initPlugin];
}

-(void)initPlugin
{
    self.devices=[NSMutableArray new];
    [[SocketManager defaultManager] connectUDP:4156 delegate:self];
}

#pragma mark  - UDP delegate
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onUdpSocket:%@",data);
    [self handleUDP:data];
    return YES;
}

-(void)handleUDP:(NSData *)data
{
    NSData *ip=[data subdataWithRange:NSMakeRange(8, 4)];
    
    
    SocketManager *sock=[SocketManager defaultManager];
    [sock initTcp:[PackManager NSDataToIP:ip] port:1234 mode:atHome delegate:self];
    
    [self sendCmd:nil];
}

-(IBAction)sendCmd:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    NSString *cmd=@"fe000001000000000100ff";
    [sock.socket writeData:[PackManager dataFormHexString:cmd] withTimeout:-1 tag:0];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:0];
}

-(void)discoveryDevice:(NSData *)data
{
    //fe01 0001 0016 0002 313710c8a5a505004b1200 98831069354304004b1200 de00ff
    NSData *length=[data subdataWithRange:NSMakeRange(6, 2)];
    for (int i; i<[PackManager NSDataToUInt:length]; i++) {
        NSData *addr=[data subdataWithRange:NSMakeRange(8+11*i, 2)];
        //NSData *macAddr=[data subdataWithRange:NSMakeRange(11+11*i, 2)];
        [self.devices addObject:addr];//[NSString stringWithFormat:@"%ld",[PackManager NSDataToUInt:addr] ]];
    }
    [self.tableView reloadData];
}

-(IBAction)switchDevice:(id)sender
{
    UISwitch *sw=(UISwitch *)sender;
    SocketManager *sock=[SocketManager defaultManager];
    NSString *cmd=@"FE00000000040001";//
    NSMutableData *data=[NSMutableData new];
    [data appendData:[PackManager dataFormHexString:cmd]];
    Byte array[] = {0x00};
    if (sw.on) {
        array[0] = 0x01;
    }
    [data appendBytes:array length:1];
    NSData *addr=[self.devices objectAtIndex:sw.tag];
    [data appendData:addr];
    NSString *tail=@"011e00ff";
    [data appendData:[PackManager dataFormHexString:tail]];
    [sock.socket writeData:data withTimeout:-1 tag:0];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:0];
}

#pragma mark  - TCP delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    NSLog(@"data:%@,tag:%ld",data,tag);
    if (tag==0) {
        [self discoveryDevice:data];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.devices count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PluginCell";
    PluginCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    cell.label.text =[NSString stringWithFormat:@"插座%li",indexPath.row];
    cell.power.tag=indexPath.row;
    [cell.power addTarget:self action:@selector(switchDevice:) forControlEvents:UIControlEventValueChanged];
    return cell;
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
