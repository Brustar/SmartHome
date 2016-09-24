//
//  IphoneAirController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneAirController.h"
#import "RulerView.h"
@interface IphoneAirController ()<RulerViewDatasource, RulerViewDelegate>
@property (weak, nonatomic) IBOutlet RulerView *thermometerView;
@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;

@end

@implementation IphoneAirController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.thermometerView.datasource = self;
    self.thermometerView.delegate = self;
    [self.thermometerView updateCurrentValue:24];
}

#pragma mark - RulerViewDelegate
- (void)rulerView:(RulerView *)rulerView didChangedCurrentValue:(CGFloat)currentValue {
    NSInteger value = round(currentValue);
    
    NSString *valueString = [NSString stringWithFormat:@"%d ℃", (int)value];
    
    self.showTemLabel.text = valueString;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.thermometerView reloadView];
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
