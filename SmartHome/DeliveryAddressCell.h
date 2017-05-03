//
//  DeliveryAddressCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/29.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"

@protocol DeliveryAddressCellDelegate;

@interface DeliveryAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *selectTitleLabel;
@property (nonatomic, assign) id<DeliveryAddressCellDelegate>delegate;
- (IBAction)selectBtnClicked:(id)sender;
- (IBAction)deleteBtnClicked:(id)sender;
- (IBAction)editBtnClicked:(id)sender;
- (void)setAddress:(Address *)info;
@end


@protocol DeliveryAddressCellDelegate <NSObject>

@optional
- (void)onSelectBtnClicked:(UIButton *)btn;
- (void)onEditBtnClicked:(UIButton *)btn;
- (void)onDeleteBtnClicked:(UIButton *)btn;

@end
