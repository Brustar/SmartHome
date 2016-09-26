//
//  IphoneDVDController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneDVDController.h"

@interface IphoneDVDController ()
@property (weak, nonatomic) IBOutlet UIImageView *voiceStrongImg;
@property (weak, nonatomic) IBOutlet UIImageView *voiceWeakImg;
@property (weak, nonatomic) IBOutlet UIView *touchPad;
@property (weak, nonatomic) IBOutlet UISlider *volume;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;


@end

@implementation IphoneDVDController

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
