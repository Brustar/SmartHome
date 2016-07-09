//
//  FinishRegisterViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FinishRegisterViewController.h"

@interface FinishRegisterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userName;


@end

@implementation FinishRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName.text = self.userStr;
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
