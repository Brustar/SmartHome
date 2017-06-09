//
//  KeypadView.h
//  SmartHome
//
//  Created by Brustar on 2017/6/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeypadView : UIView
@property (weak, nonatomic) IBOutlet UITextField *channelValue;
@property (nonatomic,strong) NSString *deviceid;
@end
