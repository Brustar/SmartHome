//
//  DeviceListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceListController.h"
#import "Scene.h"
#import "SceneManager.h"
#import "DeviceManager.h"
#import "Device.h"
#import "MBProgressHUD+NJ.h"
@interface DeviceListController ()<UITableViewDelegate,UITableViewDataSource,UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHight;

@end

@implementation DeviceListController

-(void)setRoomid:(NSInteger)roomid
{
    _roomid = roomid;
    self.devices = [DeviceManager devicesByRoomId:roomid];
    self.tableViewHight.constant = self.devices.count * self.tableView.rowHeight;
    if(self.isViewLoaded)
    {
        
       [self.tableView reloadData];
    }
    
}
    


-(void) viewDidLoad

{
    
    
    
    self.segues=[NSArray arrayWithObjects:@"Lighter" ,@"Curtain",@"TV"  ,@"DVD" ,@"Netv",@"FM",@"Guard",@"Camera",@"Air",nil];
    self.tableView.rowHeight=44;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.masksToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}
-(IBAction)remove:(id)sender
{
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setReadonly:NO];
    [[SceneManager defaultManager] delScenen:scene];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
#pragma mark - SplitViewController

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Device *device = self.devices[indexPath.row];
    cell.textLabel.text=device.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    self.deviceid=[NSString stringWithFormat:@"%ld",indexPath.row+1];
    NSString *segua=@"Lighter";
    if (indexPath.row<9) {
        segua=[self.segues objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:segua sender:self];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
    [theSegue setValue:self.sceneid forKey:@"sceneid"];
}


@end
