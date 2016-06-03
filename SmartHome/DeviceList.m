//
//  DeviceList.m
//  SmartHome
//
//  Created by Brustar on 16/5/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceList.h"
#import "Scene.h"
#import "SceneManager.h"

@interface DeviceList ()

@end

@implementation DeviceList

-(void) viewDidLoad
{
    
    self.devices=[NSArray arrayWithObjects:@"灯" ,@"电视" ,@"窗帘" ,@"DVD" ,@"摄像头" ,@"门禁" ,@"空调" ,@"机顶盒",@"收音机" ,nil];
    self.title=@"设备列表";
    self.tableView.rowHeight=44;
    
    if (self.sceneid>0) {
        UISegmentedControl *button = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"删除", nil]];
        button.momentary = YES;
        [button addTarget:self action:@selector(remove:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = menuButton;
    }
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
    NSString *segua=@"Lighter";
    if (indexPath.row==0) {
        segua=@"Lighter";
    }else if (indexPath.row==2){
        segua=@"Curtain";
    }
    [self performSegueWithIdentifier:segua sender:self];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        id theSegue = segue.destinationViewController;
        [theSegue setValue:self.sceneid forKey:@"sceneid"];

}

@end
