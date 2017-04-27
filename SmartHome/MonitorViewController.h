//
//  MonitorViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/26.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSPPlayer.h"

#define Video_Output_Width  UI_SCREEN_WIDTH-120
#define Video_Output_Height 160
#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)

@interface MonitorViewController : UIViewController
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *cameraURL;
@property (nonatomic, strong) NSString *roomName;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImgView;
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (nonatomic,strong) RTSPPlayer *video;
@property (nonatomic) float lastFrameTime;
@property (nonatomic, retain) NSTimer *nextFrameTimer;

- (IBAction)adjustBtnClicked:(id)sender;
- (IBAction)fullScreenBtnClicked:(id)sender;

@end
