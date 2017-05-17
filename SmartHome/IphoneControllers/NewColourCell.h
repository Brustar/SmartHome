//
//  NewColourCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/19.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewColourCellDelegate;

@interface NewColourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *colourNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *colourBtn;
@property (weak, nonatomic) IBOutlet UISlider *colourSlider;
@property (weak, nonatomic) IBOutlet UIImageView *supimageView;
@property (weak, nonatomic) IBOutlet UIImageView *lowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highImageView;
@property (weak, nonatomic) IBOutlet UIButton *AddColourLightBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ColourLightConstraint;
@property(nonatomic, strong) NSString * deviceid;
@property (nonatomic,strong) NSString *sceneid;
//房间id
@property (nonatomic,assign) NSInteger roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<NewColourCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ColourNameTopConstraint;

@end


@protocol NewColourCellDelegate <NSObject>

@optional
- (void)onColourSwitchBtnClicked:(UIButton *)btn;


@end
