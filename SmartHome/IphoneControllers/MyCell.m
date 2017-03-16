//
//  MyCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        //        self.imageView.textAlignment = NSTextAlignmentCenter;
        //        self.imageView.font = [UIFont boldSystemFontOfSize:50.0];
        self.imageView.backgroundColor = [UIColor underPageBackgroundColor];
        //        self.imageView.image = [U];
        [self.contentView addSubview:self.imageView];
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        
    }
    return self;
}
@end
