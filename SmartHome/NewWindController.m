//
//  NewWindController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/9/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NewWindController.h"

@interface NewWindController ()

@end

@implementation NewWindController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


- (IBAction)powerBtnClicked:(id)sender {
     UIButton *btn = (UIButton *)sender;
     btn.selected = !btn.selected;
    if (btn.selected) {
        //发开指令 和 送风指令
        
    }else {
        //发关指令
        
    }
}

- (IBAction)highSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.middleSpeedBtn.selected = NO;
            self.lowSpeedBtn.selected = NO;
            // 发高速指令
            
        }
    }
}

- (IBAction)middleSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.highSpeedBtn.selected = NO;
            self.lowSpeedBtn.selected = NO;
            // 发中速指令
            
        }
    }
}

- (IBAction)lowSpeedBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }else {
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.middleSpeedBtn.selected = NO;
            self.highSpeedBtn.selected = NO;
            // 发低速指令
            
        }
    }
}
@end
