//
//  ScreenCurtainController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScreenCurtainController.h"
#import "DetailTableViewCell.h"
#import "DeviceManager.h"



@interface ScreenCurtainController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) NSMutableArray *screenCurtainNames;
@property (nonatomic,strong) NSMutableArray *screenCurtainIds;
@property (nonatomic,strong) DetailTableViewCell *cell;

@end

@implementation ScreenCurtainController

-(NSMutableArray *)screenCurtainIds
{
    if(!_screenCurtainIds)
    {
        _screenCurtainIds = [NSMutableArray array];
        if(self.sceneid > 0 )
        {
            NSArray *screenCurtain = [DeviceManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i < screenCurtain.count; i++)
            {
                NSString *typeName = [DeviceManager deviceTypeNameByDeviceID:[screenCurtain[i] intValue]];
                if([typeName isEqualToString:@"幕布"])
                {
                    [_screenCurtainIds addObject:screenCurtain[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_screenCurtainIds addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"幕布" andRoomID:self.roomID]];
        }else{
            [_screenCurtainIds addObject:self.deviceid];
        }
    }
    return _screenCurtainIds;
}
-(NSMutableArray *)screenCurtainNames
{
    if(!_screenCurtainNames)
    {
        _screenCurtainNames = [NSMutableArray array];
        for(int i = 0; i < self.screenCurtainIds.count; i++)
        {
            int screenCurtainID = [self.screenCurtainIds[i] intValue];
            [_screenCurtainNames addObject:[DeviceManager deviceNameByDeviceID:screenCurtainID]];
        }
 
    }
    return _screenCurtainNames;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"幕布";
    [self setupSeguentScreenCurtain];
}

-(void)setupSeguentScreenCurtain
{
    if(self.screenCurtainNames == nil || self.screenCurtainNames.count == 0)
    {
        return;
        
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.screenCurtainNames.count; i++)
    {
        [self.segment insertSegmentWithTitle:self.screenCurtainNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [self.screenCurtainIds objectAtIndex:self.segment.selectedSegmentIndex];
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
        cell.label.text = self.screenCurtainNames[self.segment.selectedSegmentIndex];
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
        [self performSegueWithIdentifier:@"screenCurtainDetailSegue" sender:self];
    }
}

- (IBAction)selectedScreenCurtain:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.cell.label.text = self.screenCurtainNames[segment.selectedSegmentIndex];
    self.deviceid=[self.screenCurtainIds objectAtIndex:self.segment.selectedSegmentIndex];
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
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
