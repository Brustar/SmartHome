//
//  RealScene.m
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RealScene.h"

@interface RealScene ()

@end

@implementation RealScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.realimg=[[TouchImage alloc] initWithFrame:CGRectMake(100, 40, 625, 500)];
    self.realimg.image =[UIImage imageNamed:@"real.png"];
    self.realimg.userInteractionEnabled=YES;
    self.realimg.viewFrom=REAL_IMAGE;
    [self.view addSubview:self.realimg];
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
