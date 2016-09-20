//
//  DetailTableViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DetailTableViewCell.h"

@implementation DetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
     {
         self.brightWidthConstraint.constant = 100;
         
     }else {
         self.brightWidthConstraint.constant = 200;
     }
    
    
    
}
- (IBAction)brightValueChanged:(id)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f%%",self.bright.value *100];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
