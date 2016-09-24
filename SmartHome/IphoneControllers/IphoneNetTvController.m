//
//  IphoneNetTvController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneNetTvController.h"

@interface IphoneNetTvController ()
@property (weak, nonatomic) IBOutlet UIImageView *voiceWeakImg;
@property (weak, nonatomic) IBOutlet UIImageView *voiceStrongImg;
@property (weak, nonatomic) IBOutlet UIView *touchpad;
//那6个控制按钮，button的tag值不一样，分别是0 到 5
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation IphoneNetTvController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.volume.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceWeakImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceStrongImg.transform = CGAffineTransformMakeRotation(M_PI/2);

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
