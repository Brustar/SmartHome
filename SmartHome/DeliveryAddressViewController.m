//
//  DeliveryAddressViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/28.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeliveryAddressViewController.h"

@interface DeliveryAddressViewController ()

@end

@implementation DeliveryAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"收货地址管理"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
    }
    if (Is_iPhoneX) {
        self.addressTableViewConstraint.constant = 88;
        self.AddressButtonConstraint.constant = 30;
        self.AddressTableViewBottom.constant = 60;
    }
    _addressArray = [NSMutableArray array];
    self.addressTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.addressTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addNotifications];
    [self fetchAddressList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchAddressList {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_address.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(0)
                               };
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {//地址列表
        [_addressArray removeAllObjects];
        if ([responseObject[@"result"] intValue] == 0) {
            NSArray *addressList = responseObject[@"address_list"];
            if ([addressList isKindOfClass:[NSArray class]]) {
                for (NSDictionary *address in addressList) {
                    if ([address isKindOfClass:[NSDictionary class]]) {
                        Address *info = [[Address alloc] init];
                        info.addressID = [address[@"rid"] integerValue];
                        info.userName = address[@"contact_name"];
                        info.phoneNum = address[@"contact_number"];
                        info.province = address[@"province"];
                        info.city = address[@"city"];
                        info.region = address[@"region"];
                        info.street = address[@"street"];
                        info.addressDetail = address[@"address"];
                        info.isDefault = [address[@"isdefault"] integerValue];
                        
                        [_addressArray addObject:info];
                        
                    }
                }
            }
            
            [self.addressTableView reloadData];
        }
    }else if (tag == 2) { //设置默认地址
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"设置默认地址成功"];
            [self fetchAddressList];
        }else {
            [MBProgressHUD showError:@"设置默认地址失败"];
        }
    }else if (tag == 3) { //删除地址
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"删除成功"];
            [self fetchAddressList];
        }else {
            [MBProgressHUD showError:@"删除失败"];
        }
    }
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _addressArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 20.0f)];
    footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"addressCell";
    DeliveryAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DeliveryAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Address *info = [_addressArray objectAtIndex:indexPath.section];
    cell.delegate = self;
    cell.selectBtn.tag = indexPath.section;
    cell.editBtn.tag = indexPath.section;
    cell.deleteBtn.tag = indexPath.section;
    [cell setAddress:info];
    
    return cell;
}

#pragma mark - DeliveryAddressCellDelegate
- (void)onSelectBtnClicked:(UIButton *)btn {
    if (_addressArray.count > btn.tag) {
        Address *info = [_addressArray objectAtIndex:btn.tag];
        if (info && !info.isDefault) {
            NSString *url = [NSString stringWithFormat:@"%@Cloud/user_address.aspx",[IOManager httpAddr]];
            NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
            
            if (auothorToken.length >0) {
                NSDictionary *dict = @{@"token":auothorToken,
                                       @"optype":@(2),
                                       @"rid":@(info.addressID)
                                       };
                HttpManager *http=[HttpManager defaultManager];
                http.delegate = self;
                http.tag = 2;
                [http sendPost:url param:dict];
            }
        }
    }
}

- (void)onEditBtnClicked:(UIButton *)btn {
    if (_addressArray.count > btn.tag) {
        Address *info = [_addressArray objectAtIndex:btn.tag];
        if (info) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
            DeliveryAddressSettingViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"DeliveryAddressSettingVC"];
            vc.optype = 4;// 编辑
            vc.addressID = info.addressID;
            vc.contact_name = info.userName;
            vc.phone_number = info.phoneNum;
            vc.province = info.province;
            vc.city = info.city;
            vc.area = info.region;
            vc.street = info.street;
            vc.addressDetail = info.addressDetail;
            vc.isDefault = info.isDefault;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)onDeleteBtnClicked:(UIButton *)btn {
    
    if (ON_IPAD) {
        if ( _addressArray.count > btn.tag ) {
            Address *info = [_addressArray objectAtIndex:btn.tag];
            if (info) {
                NSString *url = [NSString stringWithFormat:@"%@Cloud/user_address.aspx",[IOManager httpAddr]];
                NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
                
                if (auothorToken.length >0) {
                    NSDictionary *dict = @{@"token":auothorToken,
                                           @"optype":@(1),
                                           @"rid":@(info.addressID)
                                           };
                    HttpManager *http=[HttpManager defaultManager];
                    http.delegate = self;
                    http.tag = 3;
                    [http sendPost:url param:dict];
                }
            }
        }
        return;
    }
    
    UIAlertController * alerController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:ON_IPAD?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if ( _addressArray.count > btn.tag ) {
            Address *info = [_addressArray objectAtIndex:btn.tag];
            if (info) {
                NSString *url = [NSString stringWithFormat:@"%@Cloud/user_address.aspx",[IOManager httpAddr]];
                NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
                
                if (auothorToken.length >0) {
                    NSDictionary *dict = @{@"token":auothorToken,
                                           @"optype":@(1),
                                           @"rid":@(info.addressID)
                                           };
                    HttpManager *http=[HttpManager defaultManager];
                    http.delegate = self;
                    http.tag = 3;
                    [http sendPost:url param:dict];
                }
            }
        }
        
        
    }]];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }]];
    
    [self presentViewController:alerController animated:YES completion:^{
        
    }];
    
}

- (IBAction)addBtnClicked:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    DeliveryAddressSettingViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"DeliveryAddressSettingVC"];
    vc.optype = 3;// 添加
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(fetchAddressList) name:@"fetchAddressListNotification" object:nil];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)dealloc {
    [self removeNotifications];
}
@end
