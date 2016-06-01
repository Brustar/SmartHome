//
//  planeScene.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "planeScene.h"

@interface planeScene ()

@end

@implementation planeScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.planeimg=[[TouchImage alloc] initWithFrame:CGRectMake(100, 40, 625, 500)];
    self.planeimg.image =[UIImage imageNamed:@"plane.png"];
    self.planeimg.userInteractionEnabled=YES;
    self.planeimg.viewFrom=PLANE_IMAGE;
    self.planeimg.delegate=self;
    [self.view addSubview:self.planeimg];
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
