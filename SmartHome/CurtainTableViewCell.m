//
//  CurtainTableViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CurtainTableViewCell.h"

@interface CurtainTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderWidthConstraint;

@end
@implementation CurtainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.sliderWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width *0.3;
        
    }

}


- (IBAction)brightValueChanged:(id)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f%%",self.slider.value *100];
    if([self.open isSelected])
    {
        self.valueLabel.text = @"100%";
        
    }
    if([self.close isSelected])
    {
        self.valueLabel.text = @"0%";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
