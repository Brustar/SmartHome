//
//  TVIconController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVIconController.h"

@interface TVIconController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *tvIcons;
@end

@implementation TVIconController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tvIcons = @[@"cctv1.png", @"cctv2.png", @"cctv3.png", @"fengHuang.png", @"fuJian.png", @"guangDong.png", @"guangXi.png", @"guiZhou.png", @"haiNan.png", @"heBei.png", @"heiLongjiang.png", @"heNan.png", @"huBei.png", @"huNan.png", @"jiangSu.png", @"jiangXi.png", @"liaoNing.png", @"shanDong.png", @"shangHai.png", @"shenZhen.png", @"siChuan.png", @"south.png", @"tianJin.png", @"travel.png", @"zheJiang.png", @"guangDongWeiShi.png", @"MTV.png", @"neiMenggu.png", @"ningXia.png"];
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tvIcons.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.tvIcons[indexPath.row]]];

    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate tvIconController:self withImgName:self.tvIcons[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

*/

@end
