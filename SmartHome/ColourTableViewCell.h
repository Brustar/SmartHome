//
//  ColourTableViewCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@protocol ColourTableViewCellDelegate;


@interface ColourTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lable;
@property (weak, nonatomic) IBOutlet UIView *colourView;
@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;
@property (nonatomic, assign) int deviceid;
@property (nonatomic, assign) id<ColourTableViewCellDelegate> delegate;
- (IBAction)lightSwitchChanged:(id)sender;

@end

@protocol ColourTableViewCellDelegate <NSObject>

@optional
-(void)lightSwitchValueChanged:(UISwitch *)lightSwitch deviceID:(int)deviceID;

@end
