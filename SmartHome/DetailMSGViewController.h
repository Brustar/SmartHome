//
//  DetailMSGViewController.h
//  SmartHome
//
//  Created by zhaona on 2016/11/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface DetailMSGViewController : CustomViewController

@property (nonatomic,strong) NSString * itemID;
@property (nonatomic,strong) NSString * type;
@property (nonatomic, strong) NSNumber *actcode;//消息类型

@end
