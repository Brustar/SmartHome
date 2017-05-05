//
//  VoiceOrderController.h
//  SmartHome
//
//  Created by Brustar on 16/8/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "CustomViewController.h"
//引入语音合成类
@class IFlySpeechSynthesizer;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

@interface VoiceOrderController : CustomViewController<IFlySpeechRecognizerDelegate>


//声明语音合成的对象
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end
