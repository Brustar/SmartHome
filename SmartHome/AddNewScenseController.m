//
//  AddNewScenseController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//


#import "AddNewScenseController.h"
#import "AddSenseCell.h"
#import "LightController.h"

#import "DeviceListController.h"
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

@interface AddNewScenseController ()<UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *roomTableView;



@property (nonatomic,strong) NSArray *rooms;

@property (nonatomic,assign) NSInteger row;

@property (nonatomic,strong) LightController *lightVC;
@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (nonatomic,strong) DeviceListController *deviceVC;

@end

@implementation AddNewScenseController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.rooms = @[@"客厅",@"主卧",@"客卧"];
    self.roomTableView.backgroundColor = backGroudColour;
    self.roomTableView.tableFooterView = [UIView new];
    
    self.deviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"deviceViewController"];
//    self.deviceVC.tableView.frame = self.view.bounds;
//    [self.deviceView addSubview:self.deviceVC.tableView];
    
    
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return self.rooms.count;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
       AddSenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddSenseCell"];
        
        cell.roomName.text = self.rooms[indexPath.row];
        cell.backgroundColor = backGroudColour;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
        
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.row inSection:0];
        
        AddSenseCell *lastcell = [tableView cellForRowAtIndexPath:lastIndex];
        lastcell.selectedImg.hidden = YES;
        
        AddSenseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selectedImg.hidden = NO;
        
        self.row = indexPath.row;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
