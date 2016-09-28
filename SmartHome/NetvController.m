//
//  NetvController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "NetvController.h"
#import "Netv.h"
#import "SceneManager.h"
#import "DVCollectionViewCell.h"
#import "VolumeManager.h"
#import "SocketManager.h"
#import "SCWaveAnimationView.h"
#import "SQLManager.h"
#import "PackManager.h"

@interface NetvController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *touchpad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *netTvRightViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *netTvRightViewWidth;
@property (nonatomic,strong) NSArray  *netTVImages;

@property (weak, nonatomic) IBOutlet UILabel *voiceValue;

@end

@implementation NetvController

-(NSArray *)netTVImages
{
    if(!_netTVImages)
    {
        _netTVImages =  @[@"rewind",@"broadcast",@"fastForward",@"last",@"pause",@"next",@"stop",@"left",@"house",@"quiet"];
    }
    return _netTVImages;
}

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    
    self.deviceid = [SQLManager deviceIDWithRoomID:self.roomID withType:@"机顶盒"];
    
    
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    self.netTvRightViewWidth.constant = 400;
    self.netTvRightViewHeight.constant = self.netTvRightViewWidth.constant;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"机顶盒";
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start];
    if ([self.sceneid intValue]>0) {
        
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Netv class]]) {
                self.volume.value=((Netv*)[_scene.devices objectAtIndex:i]).nvolume/100.0;
            }
        }
    }
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
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
    
    [SCWaveAnimationView waveAnimationAtDirection:recognizer.direction view:self.touchpad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.volume]) {
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    Netv *device=[[Netv alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setNvolume:self.volume.value*100];
    
    
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
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_DOWN || proto.action.state == PROTOCOL_MUTE) {
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

#pragma mark - UICollectionDelegate
-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collectionCellID = @"collectionCell";
    DVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[DVCollectionViewCell alloc]init];
    }
    NSString *imageName = [NSString stringWithFormat:@"%@",self.netTVImages[indexPath.row]];
    [cell.btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    cell.btn.tag=indexPath.row;
    [cell.btn addTarget:self action:@selector(control:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(IBAction)control:(id)sender
{
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    switch (((UIButton *)sender).tag) {
        case 0:
            data=[device backward:self.deviceid];
            break;
        case 1:
            data=[device confirm:self.deviceid];
            break;
        case 2:
            data=[device forward:self.deviceid];
            break;
        case 3:
            data=[device previous:self.deviceid];
            break;
        case 4:
            data=[device pause:self.deviceid];
            break;
        case 5:
            data=[device next:self.deviceid];
            break;
        case 6:
            data=[device stop:self.deviceid];
            break;
        case 7:
            data=[device back:self.deviceid];
            break;
        case 8:
            data=[device NETVhome:self.deviceid];
            break;
        case 9:
            data=[device mute:self.deviceid];
            break;
            
        default:
            break;
    }
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
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
    CGRect rect=[self.touchpad convertRect:self.touchpad.bounds toView:self.view];
    if (CGRectContainsPoint(rect,touchPoint)) {
        NSLog(@"%.0fx%.0fpx", touchPoint.x, touchPoint.y);
        [SCWaveAnimationView waveAnimationAtPosition:touchPoint];
    }
}

- (IBAction)confromBtn:(UIButton *)sender {
    NSData *data=[[DeviceInfo defaultManager] confirm:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

@end
