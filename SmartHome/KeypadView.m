//
//  KeypadView.m
//  SmartHome
//
//  Created by Brustar on 2017/6/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "KeypadView.h"
#import "SocketManager.h"
#import "UIView+Popup.h"
@implementation KeypadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)keyPress:(id)sender {
    UIButton *keypad = (UIButton *)sender;
    self.channelValue.text = [NSString stringWithFormat:@"%@%d",self.channelValue.text , (int)keypad.tag];
}

- (IBAction)backspace:(id)sender {
    self.channelValue.text = @"";
}

- (IBAction)confrim:(id)sender {
    NSData *data = [[DeviceInfo defaultManager] switchProgram:[self.channelValue.text intValue] deviceID:self.deviceid];
    [[[SocketManager defaultManager] socket] writeData:data withTimeout:1 tag:1];
    [self dismiss];
}

@end
