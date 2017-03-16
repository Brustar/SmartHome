//
//  MyCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface MyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (nonatomic,assign) int sceneID;
@end
