//
//  AmplifierController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AmplifierController.h"
#import "DetailTableViewCell.h"
#import "DeviceManager.h"

@interface AmplifierController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic,strong) DetailTableViewCell *cell;
@property (nonatomic,strong) NSMutableArray *amplifierNames;
@property (nonatomic,strong) NSMutableArray *amplifierIDArr;
@end

@implementation AmplifierController

-(NSMutableArray *)amplifierIDArr
{
    if(!_amplifierIDArr)
    {
        _amplifierIDArr = [NSMutableArray array];
        
        if(self.sceneid > 0)
        {
            NSArray *amplifiers = [DeviceManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i<amplifiers.count; i++)
            {
                NSString *typeName = [DeviceManager deviceTypeNameByDeviceID:[amplifiers[i] intValue]];
                if([typeName isEqualToString:@"功放"])
                {
                    [_amplifierIDArr addObject:amplifiers[i]];
                }

            }
        }else if(self.roomID)
        {
            [_amplifierIDArr addObjectsFromArray:[DeviceManager getDeviceByTypeName:@"功放" andRoomID:self.roomID]];
        }else{
            [_amplifierIDArr addObject:self.deviceid];
        }
        
    }
    return _amplifierIDArr;
}

-(NSMutableArray *)amplifierNames
{
    if(!_amplifierNames)
    {
        _amplifierNames = [NSMutableArray array];
        for(int i = 0; i < self.amplifierIDArr.count; i++)
        {
            int amplifierID = [self.amplifierIDArr[i] intValue];
            [_amplifierNames addObject:[DeviceManager deviceNameByDeviceID:amplifierID]];
        }
    }
    return _amplifierNames;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功放";
    
    [self setupSegmenAmplifier];
    // Do any additional setup after loading the view.
}

-(void)setupSegmenAmplifier
{
    if(self.amplifierNames == nil)
    {
        return;
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.amplifierNames.count; i++)
    {
        [self.segment insertSegmentWithTitle:self.amplifierNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [self.amplifierIDArr objectAtIndex:self.segment.selectedSegmentIndex];
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
        self.cell = cell;
        self.cell.label.text = self.amplifierNames[self.segment.selectedSegmentIndex];
        
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"recell"];
            cell.textLabel.text = @"详细信息";
        }
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 30)];
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
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
}

- (IBAction)selectedAmplifier:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.cell.label.text = self.amplifierNames[segment.selectedSegmentIndex];
    self.deviceid=[self.amplifierIDArr objectAtIndex:self.segment.selectedSegmentIndex];
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
