//
//  RegisterDetailController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
@interface RegisterDetailController : UIViewController <HttpDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (nonatomic,strong) NSString *phoneStr;
@property (nonatomic,strong) NSString *userType;
@property (weak, nonatomic) IBOutlet UIImageView *checkPwdImageView;
@property (nonatomic,strong) NSString *MasterID;
@end
