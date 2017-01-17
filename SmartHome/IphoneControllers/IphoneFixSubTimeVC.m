//
//  IphoneFixSubTimeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/1/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneFixSubTimeVC.h"

@interface IphoneFixSubTimeVC ()
@property (weak, nonatomic) IBOutlet UIButton *showTimeBtn;//展示和修改定时的Btn
@property (weak, nonatomic) IBOutlet UISwitch *PowerSwitch;//是否启动按钮
@property (weak, nonatomic) IBOutlet UILabel *showTimeLabel;//显示几个小时的label
@property (weak, nonatomic) IBOutlet UISlider *changeSlider;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation IphoneFixSubTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createDatePicker];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/247 green:255.0/247 blue:255.0/249 alpha:1];
}
-(void)createDatePicker
{
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];

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

@end
