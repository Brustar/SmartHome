//
//  CYPhotoCell.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYPhotoCell.h"

@interface CYPhotoCell()


@end

@implementation CYPhotoCell

- (void)awakeFromNib {
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 10;
}
- (void)setSceneInfo:(Scene *)info {

    [self.imageView sd_setImageWithURL:[NSURL URLWithString: info.picName] placeholderImage:[UIImage imageNamed:@"PL"]];

}
//- (void)setImageName:(NSString *)imageName
//{
//    _imageName = [imageName copy];
//    
//    self.imageView.image = [UIImage imageNamed:imageName];
//}

@end
