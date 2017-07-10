//
//  SingleMaskView.m
//
//  Created by KobeBryant on 17/6/23.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "SingleMaskView.h"

@interface SingleMaskView ()

@property (nonatomic, weak)   CAShapeLayer   *fillLayer;
@property (nonatomic, strong) UIBezierPath   *overlayPath;
@property (nonatomic, strong) NSMutableArray *transparentPaths;   // 透明区数组

@end

@implementation SingleMaskView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: [UIScreen mainScreen].bounds];
    if (self) {
        [self setUp];
    }
    
    return self;
}


- (void)setUp {
    self.backgroundColor = [UIColor clearColor];
    self.maskColor       = [UIColor colorWithWhite:0 alpha:0.7]; // default 50% transparent black
    
    self.fillLayer.path      = self.overlayPath.CGPath;
    self.fillLayer.fillRule  = kCAFillRuleEvenOdd;
    self.fillLayer.fillColor = self.maskColor.CGColor;
    
    
    //下一步
    CGFloat centerGap = 60;
    CGFloat width = 63;
    CGFloat height = 26;
    CGFloat ori_x = (UI_SCREEN_WIDTH-width*2-centerGap)/2;
    CGFloat ori_y = UI_SCREEN_HEIGHT - 60;
    if (ON_IPAD) {
        ori_y = UI_SCREEN_HEIGHT - 140;
    }
    _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(ori_x, ori_y, width, height)];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"maskNext"] forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nextBtn];
    
    //跳过
    _skipBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nextBtn.frame)+centerGap, FY(_nextBtn), width, height)];
    [_skipBtn setBackgroundImage:[UIImage imageNamed:@"maskSkip"] forState:UIControlStateNormal];
    [_skipBtn addTarget:self action:@selector(skipBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_skipBtn];
    
    
   // UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMaskView)];
   //  [self addGestureRecognizer:tapGesture];
}

- (void)nextBtnClicked:(UIButton *)btn {
    
    [self dismissMaskView];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onNextButtonClicked: pageType:)]) {
        [_delegate onNextButtonClicked:btn pageType:self.pageType];
    }
}

- (void)skipBtnClicked:(UIButton *)btn {
    [self dismissMaskView];
    if (_delegate && [_delegate respondsToSelector:@selector(onSkipButtonClicked:)]) {
        [_delegate onSkipButtonClicked:btn];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self refreshMask];
}


- (void)refreshMask {
    
    UIBezierPath *overlayPath = [self generateOverlayPath];
    
    for (UIBezierPath *transparentPath in self.transparentPaths) {
        [overlayPath appendPath:transparentPath];
    }

    self.overlayPath = overlayPath;
    
    self.fillLayer.frame     = self.bounds;
    self.fillLayer.path      = self.overlayPath.CGPath;
    self.fillLayer.fillColor = self.maskColor.CGColor;
}



- (UIBezierPath *)generateOverlayPath {
    
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    return overlayPath;
}



- (void)addTransparentPath:(UIBezierPath *)transparentPath {
    [self.overlayPath appendPath:transparentPath];
    
    [self.transparentPaths addObject:transparentPath];
    
    self.fillLayer.path = self.overlayPath.CGPath;
}

#pragma mark - 公有方法
- (void)addTransparentBtn:(CGRect)rect tag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.tag = tag;
    [btn addTarget:self action:@selector(transparentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)transparentBtnClicked:(UIButton *)btn {
    [self dismissMaskView];
    if (_delegate && [_delegate respondsToSelector:@selector(onTransparentBtnClicked:)]) {
        [_delegate onTransparentBtnClicked:btn];
    }
}

- (void)addTransparentRect:(CGRect)rect withRadius:(CGFloat)radius{

    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    
    [self addTransparentPath:transparentPath];


}


- (void)addTransparentOvalRect:(CGRect)rect {
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [self addTransparentPath:transparentPath];
}


- (void)addImage:(UIImage*)image withFrame:(CGRect)frame{

    UIImageView * imageView   = [[UIImageView alloc]initWithFrame:frame];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image           = image;
    
    [self addSubview:imageView];
    

}


- (void)showMaskViewInView:(UIView *)view{
    
    self.alpha = 0;
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];


}


- (void)dismissMaskView{


    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    


}


#pragma mark - 懒加载Getter Methods

- (UIBezierPath *)overlayPath {
    if (!_overlayPath) {
        _overlayPath = [self generateOverlayPath];
    }
    
    return _overlayPath;
}

- (CAShapeLayer *)fillLayer {
    if (!_fillLayer) {
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.frame = self.bounds;
        [self.layer addSublayer:fillLayer];
        
        _fillLayer = fillLayer;
    }
    
    return _fillLayer;
}

- (NSMutableArray *)transparentPaths {
    if (!_transparentPaths) {
        _transparentPaths = [NSMutableArray array];
    }
    
    return _transparentPaths;
}


- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    
    [self refreshMask];
}





@end
