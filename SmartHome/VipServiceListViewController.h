//
//  VipServiceListViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/30.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "Goods.h"
#import "WeChatPayManager.h"
#import "MBProgressHUD+NJ.h"
#import "WeChatPayController.h"

@interface VipServiceListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *serviceListTableView;
@property (nonatomic, strong) NSMutableArray *serviceListArray;
@property (nonatomic, strong) NSString *out_trade_no;//商户订单号

@end
