//
//  HostListViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/3.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "HostListCell.h"

@interface HostListViewController : CustomViewController<HttpDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *hostArray;
@property (nonatomic, strong) NSString *selectedHost;
@property (weak, nonatomic) IBOutlet UITableView *hostTableView;
- (IBAction)OkBtnClicked:(id)sender;

@end
