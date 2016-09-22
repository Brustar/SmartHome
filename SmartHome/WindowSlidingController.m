//
//  WindowSlidingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define windowType @"智能推窗器"

#import "WindowSlidingController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"

@interface WindowSlidingController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *windowSlidNames;
@property (nonatomic,strong) NSMutableArray *windowSlidIds;
@property (nonatomic,strong) DetailTableViewCell *cell;
@end

@implementation WindowSlidingController

-(NSMutableArray *)windowSlidIds
{
    if(!_windowSlidIds)
    {
        _windowSlidIds = [NSMutableArray array];
        if(self.sceneid > 0 && self.isAddDevice)
        {
            NSArray *windowSlid = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < windowSlid.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[windowSlid[i] intValue]];
                if([typeName isEqualToString:windowType])
                {
                    [_windowSlidIds addObject:windowSlid[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_windowSlidIds addObjectsFromArray:[SQLManager getDeviceByTypeName:windowType andRoomID:self.roomID]];
        }else{
            [_windowSlidIds addObject:self.deviceid];
        }

    }
    return _windowSlidIds;
}
-(NSMutableArray *)windowSlidNames
{
    if(!_windowSlidNames)
    {
        _windowSlidNames = [NSMutableArray array];
        
        for(int i = 0; i < self.windowSlidIds.count; i++)
        {
            int windSlidID = [self.windowSlidIds[i] intValue];
            [_windowSlidNames addObject:[SQLManager deviceNameByDeviceID:windSlidID]];
        }

    }
    return _windowSlidNames;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = windowType;
    self.tableView.tableFooterView = [UIView new];
    [self setupSegmentWindowSlid];
    
}
-(void)setupSegmentWindowSlid
{
    if(self.windowSlidNames == nil || self.windowSlidNames.count == 0)
    {
        return;
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.windowSlidNames.count;i++)
    {
        [self.segment insertSegmentWithTitle:self.windowSlidNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [self.windowSlidIds objectAtIndex:self.segment.selectedSegmentIndex];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.label.text = self.windowSlidNames[self.segment.selectedSegmentIndex];
        self.cell = cell;
        return cell;
        
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"recell"];
            
        }
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 30)];
        [cell.contentView addSubview:label];
        label.text = @"详细信息";
        return cell;
        
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"windowSliderDetailSegue" sender:self];
    }
}
- (IBAction)selectedWindowSlider:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.cell.label.text = self.windowSlidNames[segment.selectedSegmentIndex];
    self.deviceid=[self.windowSlidIds objectAtIndex:self.segment.selectedSegmentIndex];
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
