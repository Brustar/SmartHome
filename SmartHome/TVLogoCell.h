//
//  TVLogoCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TVLogoCell;
@protocol TVLogoCellDelegate <NSObject,UIGestureRecognizerDelegate>

-(void)tvDeleteAction:(TVLogoCell *)cell;
-(void)tvEditAction:(TVLogoCell *)cell;

@end

@interface TVLogoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property(nonatomic,weak) id<TVLogoCellDelegate> delegate;

-(void)useLongPressGesture;
-(void)unUseLongPressGesture;
-(void)hiddenEditBtnAndDeleteBtn;
@end
