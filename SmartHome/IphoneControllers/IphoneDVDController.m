//
//  IphoneDVDController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneDVDController.h"
#import "DVD.h"
#import "SceneManager.h"
#import "VolumeManager.h"
#import "SocketManager.h"
#import "SCWaveAnimationView.h"
#import "SQLManager.h"
#import "PackManager.h"
#import "Light.h"

@interface IphoneDVDController ()
@property (weak, nonatomic) IBOutlet UIImageView *voiceStrongImg;
@property (weak, nonatomic) IBOutlet UIImageView *voiceWeakImg;
@property (weak, nonatomic) IBOutlet UIView *touchPad;
@property (weak, nonatomic) IBOutlet UISlider *volume;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;


@end

@implementation IphoneDVDController

- (void)setRoomID:(int)roomID
{
    
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager deviceIDWithRoomID:self.roomID withType:@"DVD"];
    }
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.volume.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceWeakImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceStrongImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    for (UIButton * button in self.buttons) {
        [button addTarget:self action:@selector(Iphonecontrol:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.title = @"DVD";
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start];
    
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[DVD class]]) {
                self.volume.value=((DVD*)[_scene.devices objectAtIndex:i]).dvolume/100.0;
            }
        }
    }
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self touchPad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self touchPad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self touchPad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self touchPad] addGestureRecognizer:recognizer];
    
    //NSData *data=[[DeviceInfo defaultManager] open:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    //[sock.socket writeData:data withTimeout:1 tag:1];
    
}
- (void)IphonehandleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    NSData *data=nil;
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            data=[[DeviceInfo defaultManager] sweepLeft:self.deviceid];
            NSLog(@"Left");
            break;
        case UISwipeGestureRecognizerDirectionRight:
            data=[[DeviceInfo defaultManager] sweepRight:self.deviceid];
            NSLog(@"right");
            break;
        case UISwipeGestureRecognizerDirectionUp:
            data=[[DeviceInfo defaultManager] sweepUp:self.deviceid];
            NSLog(@"up");
            break;
        case UISwipeGestureRecognizerDirectionDown:
            data=[[DeviceInfo defaultManager] sweepDown:self.deviceid];
            NSLog(@"down");
            break;
            
        default:
            break;
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [SCWaveAnimationView waveAnimationAtDirection:recognizer.direction view:self.touchPad];
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.volume]) {
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
//        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    }
    
    DVD *device=[[DVD alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setDvolume:self.volume.value*100];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (proto.masterID != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_VOLUME_DOWN || proto.action.state == PROTOCOL_MUTE) {
            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volume.value=[[device valueForKey:@"volume"] floatValue]*100;
        /*
         KEVolumeUtil *volumeManager=[KEVolumeUtil shareInstance];
         NSData *data=nil;
         if (volumeManager.willup) {
         data = [device volumeUp:self.deviceid];
         }else{
         data = [device volumeDown:self.deviceid];
         }
         SocketManager *sock=[SocketManager defaultManager];
         [sock.socket writeData:data withTimeout:1 tag:1];
         */
        [self save:nil];
    }
}
-(IBAction)Iphonecontrol:(id)sender
{
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    switch (((UIButton *)sender).tag) {
        case 0:
            data=[device backward:self.deviceid];
            break;
        case 1:
            data=[device play:self.deviceid];
            [self poweroffAllLighter];
            break;
        case 2:
            data=[device forward:self.deviceid];
            break;
        case 3:
            data=[device previous:self.deviceid];
            break;
        case 4:
            data=[device pause:self.deviceid];
            [self poweronAllLighter];
            break;
        case 5:
            data=[device next:self.deviceid];
            break;
//        case 6:
//            data=[device stop:self.deviceid];
//            break;
//        case 7:
//            data=[device pop:self.deviceid];
//            [self poweronAllLighter];
//            break;
//        case 8:
//            data=[device home:self.deviceid];
//            break;
            
        default:
            break;
    }
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)poweroffAllLighter
{
    SocketManager *sock=[SocketManager defaultManager];
    DeviceInfo *info=[DeviceInfo defaultManager];
    for (id device in self.scene.devices) {
        if ([device isKindOfClass:[Light class]]) {
            NSData *data = [info toogle:0x00 deviceID:[NSString stringWithFormat:@"%d", ((Light *)device).deviceID]];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

-(void)poweronAllLighter
{
    SocketManager *sock=[SocketManager defaultManager];
    DeviceInfo *info=[DeviceInfo defaultManager];
    for (id device in self.scene.devices) {
        if ([device isKindOfClass:[Light class]]) {
            NSData *data = [info toogle:0x01 deviceID:[NSString stringWithFormat:@"%d", ((Light *)device).deviceID]];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

#pragma mark - touch detection
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:[[UIApplication sharedApplication] keyWindow]];
    CGRect rect=[self.touchPad convertRect:self.touchPad.bounds toView:self.view];
    if (CGRectContainsPoint(rect,touchPoint)) {
        NSLog(@"%.0fx%.0fpx", touchPoint.x, touchPoint.y);
        [SCWaveAnimationView waveAnimationAtPosition:touchPoint];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
