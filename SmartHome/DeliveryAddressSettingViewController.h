//
//  DeliveryAddressSettingViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "AddressPickerView.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+RegMatch.h"
#import "HttpManager.h"

@interface DeliveryAddressSettingViewController : CustomViewController<AddressPickerViewDelegate, HttpDelegate>
@property (weak, nonatomic) IBOutlet UIView *v1;
@property (weak, nonatomic) IBOutlet UIView *v2;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressDetailTextField;
@property (nonatomic, strong) UIButton *naviRightBtn;

@property (nonatomic, assign) NSInteger addressID;// 地址ID
@property (nonatomic, strong) NSString *contact_name;//联系人
@property (nonatomic, strong) NSString *phone_number;//电话
@property (nonatomic, strong) NSString *street;//街道
@property (nonatomic, strong) NSString *addressDetail;//详细地址
@property (nonatomic, assign) BOOL isDefault;//是否默认
@property (nonatomic, assign) NSInteger optype;//操作类型：3:添加 4:编辑
@property (nonatomic, strong) NSString *province;//省
@property (nonatomic, strong) NSString *city;//市
@property (nonatomic, strong) NSString *area;//区
@property (weak, nonatomic) IBOutlet UISwitch *defaultSwitch;

- (IBAction)areaBtnClicked:(id)sender;
@property (nonatomic ,strong) AddressPickerView * pickerView;
@end
