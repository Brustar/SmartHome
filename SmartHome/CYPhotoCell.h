//
//  CYPhotoCell.h
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface CYPhotoCell : UICollectionViewCell
/** 图片名 */
@property (nonatomic, copy) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,assign) int sceneID;

- (void)setSceneInfo:(Scene *)info;

@end
