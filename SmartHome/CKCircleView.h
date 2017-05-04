//
//  CKCircleView.h
//  CKCircleWidget
//
//  Created by Aileen Nielsen on 11/18/15.
//  Copyright © 2015 SunnysideProductions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKCircleViewDelegate <NSObject>
//开始按钮的回调数字
-(void)startTextChange:(NSString *)startText;
//结束按钮的回调文字
-(void)endTextChange:(NSString *)endText;
@end

@interface CKCircleView : UIView

@property(nonatomic,weak)id<CKCircleViewDelegate> delegate;

// set min and max range for dial
// default values are 0 to 100
@property int minNum;
@property int maxNum;
@property NSString *units;

// dial appearance
@property CGFloat dialRadius;
@property UIColor *dialColor;
@property UIImageView * dialViewImage;


@property CGFloat dialRadius2;
@property UIColor *dialColor2;

// background circle appeareance
@property CGFloat outerRadius;  // don't set this unless you want some squarish appearance
@property UIColor *backColor;

// arc appearance
@property UIColor *arcColor;
@property CGFloat arcRadius; // must be less than the outerRadius since view clips to bounds
@property CGFloat arcThickness;

// label appearance
@property UIFont *labelFont; // font is not automatically resized, so adjust to your needs
@property UIColor *labelColor;
@end
