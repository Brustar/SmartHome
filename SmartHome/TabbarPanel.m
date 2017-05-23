//
//  TabbarPanel.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/6.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "TabbarPanel.h"

@implementation TabbarPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    CGFloat leadingGap = 20;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        leadingGap = 300;
    }
    CGFloat topGap = 10;
    CGFloat btnTopGap = 0;
    CGFloat bgHeight = self.frame.size.height;
    CGFloat subBgWidth = UI_SCREEN_WIDTH-leadingGap*2;
    CGFloat subBgHeight = 50;
    CGFloat buttonWidth = subBgWidth/3;
    CGFloat buttonHeight = 50;
    CGFloat btnTitleFontSize = 15;
    
    _pannelBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, bgHeight)];
    _pannelBgView.image = [UIImage imageNamed:@"background"];
    _pannelBgView.userInteractionEnabled = YES;
    
    _pannelSubBgView = [[UIImageView alloc] initWithFrame:CGRectMake(leadingGap, topGap, subBgWidth, subBgHeight)];
    _pannelSubBgView.userInteractionEnabled = YES;
    _pannelSubBgView.image = [UIImage imageNamed:@"Slider-frame"];
    [_pannelBgView addSubview:_pannelSubBgView];
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*buttonWidth, btnTopGap, buttonWidth, buttonHeight)];
        btn.titleLabel.font = [UIFont systemFontOfSize:btnTitleFontSize];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        if (i == 0) {
            _deviceBtn = btn;
            [_deviceBtn setTitle:@"设备" forState:UIControlStateNormal];
        
            
        }else if (i == 1) {
            _homeBtn = btn;
            [_homeBtn setTitle:@"Home" forState:UIControlStateNormal];
            
        }else if (i == 2) {
            _sceneBtn = btn;
            [_sceneBtn setTitle:@"场景" forState:UIControlStateNormal];
        }
        
    }
    [_pannelSubBgView addSubview:_deviceBtn];
    [_pannelSubBgView addSubview:_homeBtn];
    [_pannelSubBgView addSubview:_sceneBtn];
    
    _sliderBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, btnTopGap, buttonWidth, buttonHeight)];
    _sliderBtn.tag = 987654;
    [_sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
    _sliderBtn.titleLabel.font = [UIFont systemFontOfSize:btnTitleFontSize];
    [_sliderBtn setTitle:@"Home" forState:UIControlStateNormal];
    [_sliderBtn addTarget:self action:@selector(sliderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_pannelSubBgView addSubview:_sliderBtn];
    
    /******************监视手势控制*****************/
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_sliderBtn addGestureRecognizer:recognizer];
    

    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_sliderBtn addGestureRecognizer:recognizer];

    [self addSubview:_pannelBgView];
    
}

- (void)btnClicked:(UIButton *)sender {
    _sliderBtn.center = sender.center;
    [_sliderBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    if (_delegate && [_delegate respondsToSelector:@selector(changeViewController:)]) {
        [_delegate changeViewController:sender];
    }
}

- (void)sliderBtnClicked:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onSliderBtnClicked:)]) {
        [_delegate onSliderBtnClicked:sender];
    }
}


//滑动事件

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    //如果往左滑
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        //先加载数据，再加载动画特效
        
        /*[self nextQuestion];
        
        self.view.frame = CGRectMake(320, 0, 320, 480);
        
        [UIViewbeginAnimations:@"animationID"context:nil];
        
        [UIViewsetAnimationDuration:0.3f];
        
        [UIViewsetAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [UIViewsetAnimationRepeatAutoreverses:NO];
        
        self.view.frame = CGRectMake(0, 0, 320, 480);
        
        [UIViewcommitAnimations];*/
        
        
        if ([_sliderBtn.titleLabel.text isEqualToString:@"场景"]) {
            _sliderBtn.center = _homeBtn.center;
            [_sliderBtn setTitle:_homeBtn.titleLabel.text forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(changeViewController:)]) {
                [_delegate changeViewController:_homeBtn];
            }
        }else if ([_sliderBtn.titleLabel.text isEqualToString:@"Home"]) {
            _sliderBtn.center = _deviceBtn.center;
            [_sliderBtn setTitle:_deviceBtn.titleLabel.text forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(changeViewController:)]) {
                [_delegate changeViewController:_deviceBtn];
            }
        }
        
    }
    
    //如果往右滑
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        if ([_sliderBtn.titleLabel.text isEqualToString:@"设备"]) {
            _sliderBtn.center = _homeBtn.center;
            [_sliderBtn setTitle:_homeBtn.titleLabel.text forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(changeViewController:)]) {
                [_delegate changeViewController:_homeBtn];
            }
        }else if ([_sliderBtn.titleLabel.text isEqualToString:@"Home"]) {
            _sliderBtn.center = _sceneBtn.center;
            [_sliderBtn setTitle:_sceneBtn.titleLabel.text forState:UIControlStateNormal];
            if (_delegate && [_delegate respondsToSelector:@selector(changeViewController:)]) {
                [_delegate changeViewController:_sceneBtn];
            }
        }
        
    }
    
}

@end
