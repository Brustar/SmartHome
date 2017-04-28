//
//  AreaSubSettingViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface AreaSubSettingViewController : CustomViewController
@property (nonatomic,strong) NSNumber  *usrID;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *identityType;
@property (nonatomic,strong) NSString * userNameTitle;
@property (nonatomic,strong) NSString * detailTextName;
@end
