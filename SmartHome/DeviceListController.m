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
@interface DeviceListController ()<UITableViewDelegate,UITableViewDataSource,UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHight;

@end

@implementation DeviceListController

-(void) viewDidLoad

{
    
    //self.devices=[NSArray arrayWithObjects:@"灯", @"窗帘" , @"电视"  , @"DVD" , @"机顶盒" , @"收音机" ,@"门禁" ,  @"摄像头"  ,@"空调" , nil];
    self.devices = [DeviceManager getDeviceType];
    self.segues=[NSArray arrayWithObjects:@"Lighter" ,@"Curtain",@"TV"  ,@"DVD" ,@"Netv",@"FM",@"Guard",@"Camera",@"Air",nil];
    self.tableView.rowHeight=44;
    self.tableViewHight.constant = self.devices.count * self.tableView.rowHeight;
//    
//    if (self.sceneid>0) {
//        _delbutt.enabled=YES;
//    }
    self.tableView.tableFooterView = [UIView new];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.masksToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
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



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devices count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text=[self.devices objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    //self.splitViewController.minimumPrimaryColumnWidth = self.view.frame.size.width;
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
