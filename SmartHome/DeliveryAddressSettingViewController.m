//
//  DeliveryAddressSettingViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeliveryAddressSettingViewController.h"

@interface DeliveryAddressSettingViewController ()

@end

@implementation DeliveryAddressSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)setupNaviBar {
    if (self.optype == 3) {
        [self setNaviBarTitle:@"添加收货地址"];
    }else {
        [self setNaviBarTitle:@"编辑收货地址"];
    }
    
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(saveBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)saveBtnClicked:(UIButton *)btn {
    if ([self checkParamsSucceed]) {
        NSString *url = [NSString stringWithFormat:@"%@Cloud/user_address.aspx",[IOManager httpAddr]];
        NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
        
        if (auothorToken.length >0) {
            if (self.optype == 3) { //添加
                NSDictionary *dict = @{@"token":auothorToken,
                                       @"optype":@(self.optype),
                                       @"contact_name":self.nameTextField.text,
                                       @"contact_number":self.phoneTextField.text,
                                       @"province":self.province,
                                       @"city":self.city,
                                       @"region":self.area,
                                       @"street":self.streetTextField.text,
                                       @"address":self.addressDetailTextField.text,
                                       @"isdefault":@(self.defaultSwitch.on)
                                       };
                HttpManager *http = [HttpManager defaultManager];
                http.delegate = self;
                http.tag = 1;
                [http sendPost:url param:dict];
            }else { //更新
                NSDictionary *dict = @{@"token":auothorToken,
                                       @"optype":@(self.optype),
                                       @"rid":@(self.addressID),
                                       @"contact_name":self.nameTextField.text,
                                       @"contact_number":self.phoneTextField.text,
                                       @"province":self.province,
                                       @"city":self.city,
                                       @"region":self.area,
                                       @"street":self.streetTextField.text,
                                       @"address":self.addressDetailTextField.text,
                                       @"isdefault":@(self.defaultSwitch.on)
                                       };
                HttpManager *http = [HttpManager defaultManager];
                http.delegate = self;
                http.tag = 2;
                [http sendPost:url param:dict];
            }
            
        }
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"添加成功"];
            [NC postNotificationName:@"fetchAddressListNotification" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [MBProgressHUD showError:@"添加失败"];
        }
    }else if(tag == 2) {
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:@"更新成功"];
            [NC postNotificationName:@"fetchAddressListNotification" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [MBProgressHUD showError:@"更新失败"];
        }
    }
}

- (void)initUI {
    [self setupNaviBar];
     [self.view addSubview:self.pickerView];
    self.v1.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
    self.v2.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
    [self.nameTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.streetTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.addressDetailTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    if (self.optype == 4) { // 编辑
        self.nameTextField.text = self.contact_name;
        self.phoneTextField.text = self.phone_number;
        self.areaLabel.text = [NSString stringWithFormat:@"%@%@%@", self.province, self.city, self.area];
        self.streetTextField.text = self.street;
        self.addressDetailTextField.text = self.addressDetail;
        self.defaultSwitch.on = self.isDefault;
    }
}

- (BOOL)checkParamsSucceed {

    BOOL result = NO;
    if (self.nameTextField.text.length <= 0) {
        [MBProgressHUD showError:@"收货人不能为空"];
        return result;
    }else if (self.phoneTextField.text.length <= 0) {
        [MBProgressHUD showError:@"联系电话不能为空"];
        return result;
    }else if (![self.phoneTextField.text isMobileNumber]) {
        [MBProgressHUD showError:@"手机号格式错误"];
        return result;
    }else if (self.areaLabel.text.length <= 0) {
        [MBProgressHUD showError:@"所在地区不能为空"];
        return result;
    }else if (self.streetTextField.text.length <= 0) {
        [MBProgressHUD showError:@"街道不能为空"];
        return result;
    }else if (self.addressDetailTextField.text.length <= 0) {
        [MBProgressHUD showError:@"详细地址不能为空"];
        return result;
    }else {
        result = YES;
    }
    
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AddressPickerViewDelegate
- (void)cancelBtnClick{
    [self.pickerView hide];
}
- (void)sureBtnClickReturnProvince:(NSString *)province City:(NSString *)city Area:(NSString *)area{
    self.province = province;
    self.city = city;
    self.area = area;
    self.areaLabel.text = [NSString stringWithFormat:@"%@%@%@",province,city,area];
    [self.pickerView hide];
}

- (IBAction)areaBtnClicked:(id)sender {
    [self.pickerView show];
}

- (AddressPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[AddressPickerView alloc] initWithFrame:CGRectMake(0, UI_SCREEN_HEIGHT , UI_SCREEN_WIDTH, 215)];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

@end
