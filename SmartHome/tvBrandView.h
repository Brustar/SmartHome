//
//  tvBrandView.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@class tvBrandView;
@protocol tvBrandViewDelegate <NSObject>

-(void)deleteTVAction:(tvBrandView *)tvBrandView;
-(void)editTVAction:(tvBrandView *)tvBrandView;

@end
@interface tvBrandView : UIView

@property (nonatomic,strong) NSArray *channelArr;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *deleteBtns;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *editBtns;
@property (nonatomic,weak) id <tvBrandViewDelegate> delegte;

-(void)useLongPressGesture;
@end
