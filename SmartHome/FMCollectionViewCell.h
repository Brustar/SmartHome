//
//  FMCollectionViewCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@class FMCollectionViewCell;
@protocol FMCollectionViewCellDelegate <NSObject,UIGestureRecognizerDelegate>

-(void)FmDeleteAction:(FMCollectionViewCell *)cell;
-(void)FmEditAction:(FMCollectionViewCell *)cell;

@end
@interface FMCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)id <FMCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *chanelNum;

@property (weak, nonatomic) IBOutlet UILabel *channelName;



@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

-(void)useLongPressGesture;
-(void)unUseLongPressGesture;
-(void)hiddenBtns;
@end
