//
//  LoginController.h
//  SmartHome
//
//  Created by Brustar on 16/5/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeReaderDelegate.h"

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
//引入语音合成类
@class IFlySpeechSynthesizer;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

@interface LoginQRController : UIViewController<QRCodeReaderDelegate,IFlySpeechSynthesizerDelegate,IFlySpeechRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *systemLabel;

@property (strong, nonatomic) IBOutlet UILabel *roleLabel;

//声明语音合成的对象
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (strong, nonatomic) IBOutlet UITextField *content;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSString * result;

- (IBAction)Start:(id)sender;

@end
