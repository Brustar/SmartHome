//
//  WelcomeController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "WelcomeController.h"
#import "DeviceInfo.h"
#import "DeviceManager.h"

@interface WelcomeController ()

@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UIView *knowView;

@end

@implementation WelcomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}


- (IBAction)clickWeKnowBtn:(id)sender {
    
    self.coverView.hidden = YES;
    self.knowView.hidden = YES;
}

- (IBAction)clickloginBtn:(id)sender {
}

- (IBAction)demo:(id)sender {
    DeviceInfo *info=[DeviceInfo defaultManager];
    info.db=@"demoDB";
    [DeviceManager initDemoSQlite];
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
