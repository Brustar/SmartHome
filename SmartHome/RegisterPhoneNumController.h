//
//  RegisterPhoneNumController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"

@interface RegisterPhoneNumController : UIViewController<HttpDelegate>
@property (weak, nonatomic) IBOutlet UILabel *UserTypeLb;
@property (weak, nonatomic) IBOutlet UILabel *MasterIDLb;
@property (nonatomic,strong) NSString *suerTypeStr;
@property (nonatomic,assign) int masterStr;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLayou;

@end
