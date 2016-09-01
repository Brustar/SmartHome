//
//  ECSearchView.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ECSearchView.h"

@implementation ECSearchView

-(id)initWithFrame:(CGRect)frame
 {
     self = [super initWithFrame:frame];
     if(self){
     [self searchView]; //调用searchView方法
  }
     return self;
}

 #pragma mark 实现searchView方法
 -(void)searchView
 {
     self.placeholder = @"搜索场景或者设备";
     //设置textField的样式
     self.borderStyle = UITextBorderStyleRoundedRect;
     //设置键盘的return键 的样式 我们更改为search字样
     self.returnKeyType = UIReturnKeySearch;
     //创建imageView对象
     UIImageView * imgView = [[UIImageView alloc]init];
     //设置 imgVIew的用户可交互性
      imgView.userInteractionEnabled = YES;
     //给 imgView赋值  tabbar_discover是一个放大镜图片
     imgView.image = [UIImage imageNamed:@"tabbar_discover"];
     //设置self (textField)的 rightView属性和 rightViewMode的属性
     self.rightView = imgView;
     self.rightViewMode = UITextFieldViewModeAlways;
     //向 这张图片添加一个手势
     UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnClick:)];
     [imgView addGestureRecognizer:tap];
    
    
    }
 //实现按钮点击事件
 -(void)btnClick:(UIButton *)btn
 {
         NSLog(@" 111111111111%@",self.text);
         NSLog(@"5555");
     }

@end
