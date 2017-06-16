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

@protocol MonitorViewControllerDelegate;

@interface MonitorViewController : UIViewController
@property (nonatomic, strong) NSString *deviceid;
@property (nonatomic, strong) NSString *cameraURL;
@property (nonatomic, strong) NSString *roomName;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImgView;
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *adjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (nonatomic,strong) RTSPPlayer *video;
@property (nonatomic) float lastFrameTime;
@property (nonatomic, retain) NSTimer *nextFrameTimer;
@property (nonatomic, assign) id<MonitorViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monitorViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adjustBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adjustBtnBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullScreenBtnBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rNameLabelBottom;

- (IBAction)adjustBtnClicked:(id)sender;
- (IBAction)fullScreenBtnClicked:(id)sender;

@end


@protocol MonitorViewControllerDelegate <NSObject>

@optional
- (void)onAdjustBtnClicked:(UIButton *)sender;
- (void)onFullScreenBtnClicked:(UIButton *)sender  cameraImageView:(UIImageView *)imageView;
- (void)showFullScreenViewByImage:(UIImage *)img;
@end
