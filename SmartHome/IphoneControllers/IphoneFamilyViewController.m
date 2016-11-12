
//
//  IphoneFamilyViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//


#import "IphoneFamilyViewController.h"


@interface IphoneFamilyViewController ()

@property (weak, nonatomic) IBOutlet UIView *supView;
@property (nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,strong)UIImageView * supImageView;
@property (nonatomic,strong) NSArray * dataSource;

@end

@implementation IphoneFamilyViewController
-(NSArray *)dataSource
{

    if (!_dataSource) {
        _dataSource = @[@"23",@"卧室",@"67%"];
    }

    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bounces = NO;
    [self.supView addSubview:self.scrollView];
    
    [self setSubImage];
}

-(void)setSubImage
{

    
    for (int i =0 ; i < 6; i ++) { //行
        for (int j = 0; j < 2; j++) { //列
            
            //父视图
            self.supImageView = [[UIImageView alloc] init];
            self.supImageView.frame = CGRectMake(160*j, 160*i, 155, 155);
            self.supImageView.backgroundColor = [UIColor lightGrayColor];
            [self.scrollView addSubview:self.supImageView];
            
            //子视图
            UIImageView * imageView = [[UIImageView alloc] init];
//            btn.frame = CGRectMake(20+100*j, 40+150*i, 75, 122);
            imageView.frame = CGRectMake(25, 25, 100, 100);
            imageView.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:0/255.0 alpha:1];
            
            [self.supImageView addSubview:imageView];
            
            imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0; //圆角半径
            imageView.layer.masksToBounds = YES; //圆角
            
            //灯视图
            UIImageView * lightView = [[UIImageView alloc] init];
            lightView.frame = CGRectMake(20, 5, 40, 40);
            lightView.backgroundColor = [UIColor colorWithRed:41/255.0 green:159/255.0 blue:83/255.0 alpha:1];
            lightView.layer.cornerRadius = lightView.bounds.size.width / 2.0; //圆角半径
            lightView.layer.masksToBounds = YES; //圆角
            [self.supImageView addSubview:lightView];
            
            //窗帘
            UIImageView * curtainView = [[UIImageView alloc] init];
            curtainView.frame = CGRectMake(90, 5, 40, 40);
            curtainView.backgroundColor = [UIColor colorWithRed:64/255.0 green:128/255.0 blue:129/255.0 alpha:1];
            curtainView.layer.cornerRadius = curtainView.bounds.size.width / 2.0; //圆角半径
            curtainView.layer.masksToBounds = YES; //圆角
            [self.supImageView addSubview:curtainView];
            
            //DVD
            UIImageView * DVDView = [[UIImageView alloc] init];
            DVDView.frame = CGRectMake(0, 70, 40, 40);
            DVDView.backgroundColor = [UIColor colorWithRed:122/255.0 green:0/255.0 blue:255/255.0 alpha:1];
            DVDView.layer.cornerRadius = DVDView.bounds.size.width / 2.0; //圆角半径
            DVDView.layer.masksToBounds = YES; //圆角
            DVDView.hidden = YES;
            [self.supImageView addSubview:DVDView];
            
            //TV
            
            UIImageView * TVView = [[UIImageView alloc] init];
            TVView.frame = CGRectMake(100, 100, 40, 40);
            TVView.backgroundColor = [UIColor colorWithRed:254/255.0 green:128/255.0 blue:0/255.0 alpha:1];
            TVView.layer.cornerRadius = TVView.bounds.size.width / 2.0; //圆角半径
            TVView.layer.masksToBounds = YES; //圆角
            [self.supImageView addSubview:TVView];
            
            //音乐
            UIImageView * musicView = [[UIImageView alloc] init];
            musicView.frame = CGRectMake(120, 55, 40, 40);
            musicView.backgroundColor = [UIColor colorWithRed:135/255.0 green:18/255.0 blue:76/255.0 alpha:1];
            musicView.layer.cornerRadius = musicView.bounds.size.width / 2.0; //圆角半径
            musicView.layer.masksToBounds = YES; //圆角
            musicView.hidden = YES;
            [self.supImageView addSubview:musicView];
            
            //空调
            
            UIImageView * airView = [[UIImageView alloc] init];
            airView.frame = CGRectMake(40, 115, 40, 40);
            airView.backgroundColor = [UIColor colorWithRed:10/255.0 green:132/255.0 blue:255/255.0 alpha:1];
            airView.layer.cornerRadius = airView.bounds.size.width / 2.0; //圆角半径
            airView.layer.masksToBounds = YES; //圆角
            [self.supImageView addSubview:airView];
            
            //温度Label
            UILabel * temperature = [[UILabel alloc] init];
            temperature.frame = CGRectMake(35, 5, 40, 30);
            temperature.text = @"32";
            temperature.font = [UIFont systemFontOfSize:18];
            temperature.textAlignment = NSTextAlignmentLeft;
            temperature.textColor = [UIColor whiteColor];
            [imageView addSubview:temperature];
            
            //房间Label
            UILabel * roomLabel = [[UILabel alloc] init];
            roomLabel.frame = CGRectMake(35, 35, 40, 30);
            roomLabel.text = @"卧室";
            roomLabel.font = [UIFont systemFontOfSize:18];
            roomLabel.textAlignment = NSTextAlignmentLeft;
            roomLabel.textColor = [UIColor whiteColor];
            [imageView addSubview:roomLabel];
            
            //使用情况Label
            UILabel * userLabel = [[UILabel alloc] init];
            userLabel.frame = CGRectMake(35, 65, 40, 30);
            userLabel.text = @"86%";
            userLabel.font = [UIFont systemFontOfSize:18];
            userLabel.textAlignment = NSTextAlignmentLeft;
            userLabel.textColor = [UIColor whiteColor];
            [imageView addSubview:userLabel];
        }
     
     
    }

    self.scrollView.frame = self.supView.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.supImageView.bounds.size.height*6+30);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
