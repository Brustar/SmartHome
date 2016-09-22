//
//  ScenseCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SceneCell;
@protocol ScenseCellDelegate <NSObject>



@end


@interface SceneCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *scenseName;


@property (weak, nonatomic) IBOutlet UIButton *powerBtn;


@end
