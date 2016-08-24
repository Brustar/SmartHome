//
//  VoiceOrderController.h
//  SmartHome
//
//  Created by Brustar on 16/8/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
//引入语音合成类
@class IFlySpeechSynthesizer;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

@interface VoiceOrderController : UIViewController<IFlySpeechSynthesizerDelegate,IFlySpeechRecognizerDelegate>


//声明语音合成的对象
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (strong, nonatomic) IBOutlet UITextField *content;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
