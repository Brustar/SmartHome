//
//  MSGController.m
//  SmartHome
//
//  Created by Brustar on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MSGController.h"
#import "IOManager.h"

@interface MSGController ()

@end

@implementation MSGController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.msgs = [[NSMutableArray alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@msgs",[IOManager httpAddr]];
    // GET
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [mgr GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success:%@",responseObject);
        for (id obj in responseObject) {
            [self.msgs addObject:obj[@"title"]];
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error);
    }];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.msgs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text=[self.msgs objectAtIndex:indexPath.row];
    cell.detailTextLabel.text=@"发送于周六";
    return cell;
}

@end
