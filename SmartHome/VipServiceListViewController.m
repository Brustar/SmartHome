//
//  VipServiceListViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/3/30.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "VipServiceListViewController.h"

@interface VipServiceListViewController ()

@end

@implementation VipServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    _serviceListArray = [NSMutableArray array];
    [self fetchServiceList];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(onWeChatPaySuccess:) name:@"WeChatPaySuccess" object:nil];
    [NC addObserver:self selector:@selector(onWeChatPayFailed:) name:@"WeChatPayFailed" object:nil];
    
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)onWeChatPaySuccess:(NSNotification *)noti {
    [self getPayResult];
}

- (void)onWeChatPayFailed:(NSNotification *)noti {
    [MBProgressHUD showError:@"支付失败"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchServiceList {
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
     NSString *url = [NSString stringWithFormat:@"%@WxPay/goods.aspx",[IOManager httpAddr]];
    NSDictionary *dict = @{@"token":authorToken,
                           @"goods_id":@(1)
                           };

    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dict];
}

//从服务器获取支付结果
- (void)getPayResult {
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"http://192.168.199.192:8086/WxPay/weixin_order_query.aspx"/*,[IOManager httpAddr]*/];
    
    if (authorToken.length >0 && _out_trade_no.length >0) {
        NSDictionary *dict = @{@"token":authorToken,
                               @"out_trade_no":_out_trade_no
                               };
        
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 3;
        [http sendPost:url param:dict];
    }
    
}

#pragma  mark -  Http Delegate
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if (tag == 1) {
        if ([responseObject[@"result"] intValue] == 0)
        {
            NSLog(@"responseObject: %@", responseObject);
            NSArray *list = responseObject[@"goods_list"];
            if ([list isKindOfClass:[NSArray class]]) {
                for (NSDictionary *goodsInfo in list) {
                    if ([goodsInfo isKindOfClass:[NSDictionary class]]) {
                        Goods *info = [[Goods alloc] init];
                        info.body = goodsInfo[@"body"];
                        info.total_fee = [goodsInfo[@"total_fee"] integerValue];
                        info.goods_id = [goodsInfo[@"goods_id"] integerValue];
                        info.goods_url = goodsInfo[@"goods_url"];
                        info.isVip = [goodsInfo[@"vip"] integerValue];
                        info.trade_type = goodsInfo[@"trade_type"];
                        info.notify_url = goodsInfo[@"notify_url"];
                        info.goods_tag = goodsInfo[@"goods_tag"];
                        info.fee_type = goodsInfo[@"fee_type"];
                        info.attach = goodsInfo[@"attach"];
                        info.detail = goodsInfo[@"detail"];
                        
                        [_serviceListArray addObject:info];
                    }
                }
            }
        }else {
            NSLog(@"HTTP ERROR: %@", responseObject[@"msg"]);
        }
        
        [self.serviceListTableView reloadData];
    }else if (tag == 2) {
        if ([responseObject[@"result"] intValue] == 0)
        {
            //NSString *sign = responseObject[@"sign"];
            NSString *prepayId = responseObject[@"prepay_id"];
            _out_trade_no = [NSString stringWithString:responseObject[@"out_trade_no"]];
            
            if (prepayId.length >0) {
                //调用微信支付
                [[WeChatPayManager sharedInstance] doPayWithPrepayId:prepayId];
            }else {
                [MBProgressHUD showError:@"支付失败"];
            }
            
        }else {
            NSLog(@"HTTP ERROR: %@", responseObject[@"msg"]);
        }
    }else if (tag == 3) {
        if ([responseObject[@"result"] intValue] == 0) {
            
            NSString *result = responseObject[@"result_code"];
            NSString *alertMsg = nil;
            if ([result isEqualToString:@"SUCCESS"]) {
                alertMsg = @"支付成功";
            }else {
                alertMsg = @"支付失败";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"支付结果" message:alertMsg preferredStyle:ON_IPAD?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else {
            
        }
    }
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _serviceListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"goodsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    Goods *goodInfo = [_serviceListArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@                 ¥%@", goodInfo.body, @(goodInfo.total_fee)];
    
    UIButton *buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];buyBtn.backgroundColor = [UIColor orangeColor];
    [buyBtn setTitle:@"开通" forState:UIControlStateNormal];
    buyBtn.tag = indexPath.row;
    buyBtn.layer.cornerRadius = 4.0;
    buyBtn.layer.masksToBounds = YES;
    [buyBtn addTarget:self action:@selector(buyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setAccessoryView:buyBtn];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)buyBtnClicked:(UIButton *)btn {
    Goods *goodsInfo = [_serviceListArray objectAtIndex:btn.tag];
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSString *url = [NSString stringWithFormat:@"%@/WxPay/UnitOrderPage.aspx", [IOManager httpAddr]];
    
    if (authorToken.length >0 && goodsInfo) {
        NSDictionary *dict = @{@"token":authorToken,
                               @"trade_type":@"APP",
                               @"goods_id":@(goodsInfo.goods_id)
                               };
        
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 2;
        [http sendPost:url param:dict];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //下单
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    
    [self removeNotifications];
}

@end
