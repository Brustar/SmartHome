//
//  BgMusicController.m
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "BgMusicController.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"
#import "SQLManager.h"
#import <AVFoundation/AVFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+Navigator.h"
#import "IphoneRoomView.h"
#import "VolumeManager.h"

@interface BgMusicController ()<IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UILabel *voiceValue;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIImageView *diskView;
@property (weak, nonatomic) IBOutlet UIImageView *pre;
@property (weak, nonatomic) IBOutlet UIImageView *next;
@property (weak, nonatomic) IBOutlet UISlider *voiceSlider;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IRLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IRight;
@property (weak, nonatomic) IBOutlet UIImageView *ear;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *prevoius;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shuffleRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shuffleTop;
@property (weak, nonatomic) IBOutlet UIButton *ipadPlay;
@property (weak, nonatomic) IBOutlet UIView *IRContainer;

@end

@implementation BgMusicController

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 1.0f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         _diskView.transform = CGAffineTransformRotate(_diskView.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!self.animating) {
        self.animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.animating = NO;
}

-(void) initSlider
{
    [self.voiceSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.voiceSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.voiceSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    int index = 0,i = 0;
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
        if (device.hTypeId == bgmusic) {
            index = i;
        }
        i++;
    }
    
    IphoneRoomView *menu = [[IphoneRoomView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width
                                                                            , 40)];
    
    menu.dataArray = deviceNames;
    menu.delegate = self;
    
    [menu setSelectButton:index];
    [self.menuContainer addSubview:menu];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    Device *device = self.menus[index];
    [self.navigationController pushViewController:[DeviceInfo calcController:device.hTypeId] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - 背景音乐",roomName];
    [self setNaviBarTitle:self.title];
    [self initSlider];
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:bgmusic byRoom:self.roomID];

    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventValueChanged];
    if ([SQLManager isIR:[self.deviceid intValue]]) {
        self.IRContainer.hidden = NO;
    }

    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [[VolumeManager defaultManager] start:nil];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    [self.lastBtn setBackgroundImage:[UIImage imageNamed:@"control_button_pressed"] forState:UIControlStateSelected];
    [self.ipadPlay setImage:[UIImage imageNamed:@"TV_on"] forState:UIControlStateSelected];
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        self.voiceLeft.constant = self.voiceRight.constant = self.IRLeft.constant = self.IRight.constant = 100;
        self.shuffleTop.constant = 40;
        self.shuffleRight.constant = 600;
        self.ear.hidden = self.btnNext.hidden = self.prevoius.hidden = self.ipadPlay.hidden = NO;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void)changeVolume
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.volume.value=proto.action.RValue/100.0;
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",proto.action.RValue];
            }
            if (proto.action.state == PROTOCOL_ON || proto.action.state == PROTOCOL_OFF) {
                self.ipadPlay.selected = proto.action.state;
                self.playBtn.selected = proto.action.state;
            }
            if (proto.action.state == PROTOCOL_ON) {
                [self startSpin];
            }
            if (proto.action.state == PROTOCOL_OFF) {
                [self stopSpin];
            }
            
        }
    }
}

- (IBAction)toogle:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    UIButton *btn = (UIButton *)sender;
    NSData *data;
    
    btn.selected = !btn.selected;
    if (btn.selected) {
        data = [[DeviceInfo defaultManager] open:self.deviceid];
        [self startSpin];
    }else{
        data = [[DeviceInfo defaultManager] close:self.deviceid];
        [self stopSpin];
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)repeat:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSData *data=[[DeviceInfo defaultManager] repeat:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)shuffle:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSData *data=[[DeviceInfo defaultManager] shuffle:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)nextMusic:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data=[[DeviceInfo defaultManager] next:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)previousMusic:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data=[[DeviceInfo defaultManager] previous:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)pauseMusic:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)volumeUP:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] volumeUp:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    int value = [self.voiceValue.text intValue]+1;
    if (value<=100) {
        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",value];
    }
    
}

- (IBAction)volumeDown:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] volumeDown:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    int value = [self.voiceValue.text intValue]-1;
    if (value>=0) {
        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",value];
    }
}

- (IBAction)playMusic:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.isSelected];
    if (btn.isSelected) {
        [btn setImage:[UIImage imageNamed:@"DVD_pause"] forState:UIControlStateNormal];
        //发送播放指令
        NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        [self startSpin];
    }else{
       [btn setImage:[UIImage imageNamed:@"DVD_play"] forState:UIControlStateNormal];
        //发送停止指令
        NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        [self stopSpin];
    }
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volume.value=[[device valueForKey:@"volume"] floatValue];
        [self changeVolume];
    }
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}

@end
