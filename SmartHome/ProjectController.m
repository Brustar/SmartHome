//
//  ProjectController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ProjectController.h"
#import "DetailTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "Scene.h"
#import "SceneManager.h"
#import "Amplifier.h"

@interface ProjectController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *projectNames;
@property (nonatomic,strong) NSMutableArray *projectIds;
@property (nonatomic,strong) DetailTableViewCell *cell;
@end

@implementation ProjectController


-(NSMutableArray *)projectIds
{
    if(!_projectIds)
    {
        _projectIds = [NSMutableArray array];
        if(self.sceneid > 0 && !self.isAddDevice)
        {
            NSArray *projects = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];

            for(int i = 0; i < projects.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[projects[i] intValue]];
                if([typeName isEqualToString:@"投影"])
                {
                    [_projectIds addObject:projects[i]];
                }
                
            }
        }else if(self.roomID)
        {
            [_projectIds addObjectsFromArray:[SQLManager getDeviceByTypeName:@"投影" andRoomID:self.roomID]];
        }else{
            [_projectIds addObject:self.deviceid];
        }
    }
    return _projectIds;
}
-(NSMutableArray *)projectNames
{
    if(!_projectNames)
    {
        _projectNames = [NSMutableArray array];
        for(int i = 0; i < self.projectIds.count; i++)
        {
            int projectID = [self.projectIds[i] intValue];
            [_projectNames addObject:[SQLManager deviceNameByDeviceID:projectID]];
        }
        
    }
    return _projectNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    self.title = @"投影";
    self.tableView.tableFooterView = [UIView new];
    [self setupSeguentProject];

}

-(void)setupSeguentProject
{
    if(self.projectNames == nil || self.projectNames.count == 0)
    {
        return;
        
    }
    [self.segment removeAllSegments];
    for(int i = 0; i < self.projectNames.count; i++)
    {
        [self.segment insertSegmentWithTitle:self.projectNames[i] atIndex:i animated:NO];
    }
    self.segment.selectedSegmentIndex = 0;
    self.deviceid = [self.projectIds objectAtIndex:self.segment.selectedSegmentIndex];

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

//        cell.label.text = self.projectNames[self.segment.selectedSegmentIndex];
        cell.label.text = @"投影";
        self.cell = cell;
        self.switchView = cell.power;//[[UISwitch alloc] initWithFrame:CGRectZero];
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        if ([self.sceneid intValue]>0) {
            for(int i=0;i<[_scene.devices count];i++)
            {
                if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Amplifier class]]) {
                    cell.power.on=((Amplifier *)[_scene.devices objectAtIndex:i]).waiting;
                }
            }
        }
        [cell.power addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
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
-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.switchView]) {
        NSData *data=[[DeviceInfo defaultManager] toogle:self.switchView.isOn deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: self.switchView.isOn];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
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
        [self performSegueWithIdentifier:@"projectDetailSegue" sender:self];
    }
}


- (IBAction)selectedProject:(id)sender {
    
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    self.cell.label.text = self.projectNames[segment.selectedSegmentIndex];
    self.deviceid=[self.projectIds objectAtIndex:self.segment.selectedSegmentIndex];
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
