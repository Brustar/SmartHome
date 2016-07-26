//
//  ECloudButton.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ECloudButton.h"

@implementation ECloudButton

- (instancetype)initWithTitle:(NSString *)title normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage
{
    if (self = [super init]) {
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        [self setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
        
        [self setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageY = 0;
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    CGFloat imageX = ( self.frame.size.width - imageW ) / 2;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    CGFloat titleY = imageH + 5;
    CGFloat titleW = self.frame.size.width;
    CGFloat titleX = 0;
    CGFloat titleH = self.frame.size.height - titleY;
    
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
}


- (void)setHighlighted:(BOOL)highlighted
{
    
}

@end
