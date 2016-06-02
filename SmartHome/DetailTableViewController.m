//
//  DetailTableViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DetailTableViewController.h"
#import "Detail.h"
#import "DetailList.h"

@interface DetailTableViewController ()
@property (nonatomic,strong) NSArray *detailArray;
@property (nonatomic,strong) NSArray *titleArr;
@end

@implementation DetailTableViewController

-(NSArray *)detailArray
{
    if(!_detailArray)
    {
        _detailArray = [DetailList getDetailListWithID:2];
    }
    return _detailArray;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self detailArray];
    self.navigationItem.title = @"详细信息";
    self.titleArr = @[@"设备",@"序列号",@"生产日期",@"保修截止日期",@"型号",@"购买价格",@"购买日期",@"生产厂商",@"保修电话",@"功率",@"输入电流",@"输入电压",@"社区推荐"];
    self.tableView.backgroundColor = [UIColor grayColor];
    self.tableView.tableFooterView = [UIView new];
    
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

    return self.detailArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    cell.textLabel.text= self.titleArr[indexPath.row];
    cell.detailTextLabel.text = self.detailArray[indexPath.row];
    

    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
