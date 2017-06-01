//
//  DVDController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DVDController.h"
#import "DVD.h"
#import "SceneManager.h"
#import "DVCollectionViewCell.h"
#import "VolumeManager.h"
#import "SocketManager.h"

#import "SQLManager.h"
#import "PackManager.h"
#import "Light.h"
#import "UIViewController+Navigator.h"

#define size 350
@interface DVDController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *dvImages;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnPop;
@property (weak, nonatomic) IBOutlet UIButton *btnUP;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;

@property (weak, nonatomic) IBOutlet UIButton *btnPrevoius;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlBottom;

@end

@implementation DVDController

-(NSArray *)dvImages
{
    if(!_dvImages)
    {
        _dvImages = @[@"rewind",@"broadcast",@"fastForward",@"last",@"pause",@"next",@"stop",@"up",@"house"];
    }
    return _dvImages;
}

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager singleDeviceWithCatalogID:DVDtype byRoom:self.roomID];
    }
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - DVD",roomName]];
    [self initSlider];
    NSArray *menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    
    [self.btnMenu setImage:[UIImage imageNamed:@"TV_menu_red"] forState:UIControlStateHighlighted];
    [self.btnUP setImage:[UIImage imageNamed:@"dir_up_red"]  forState:UIControlStateHighlighted];
    [self.btnDown setImage:[UIImage imageNamed:@"dir_down_red"]  forState:UIControlStateHighlighted];
    [self.btnLeft setImage:[UIImage imageNamed:@"dir_left_red"]  forState:UIControlStateHighlighted];
    [self.btnRight setImage:[UIImage imageNamed:@"dir_right_red"]  forState:UIControlStateHighlighted];
    [self.btnOK setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.btnPop setImage:[UIImage imageNamed:@"DVD_pop_red"] forState:UIControlStateHighlighted];
    
    [self.btnPrevoius setImage:[UIImage imageNamed:@"DVD_previous_red"] forState:UIControlStateHighlighted];
    [self.btnPlay setImage:[UIImage imageNamed:@"DVD_pause"] forState:UIControlStateSelected];
    [self.btnNext setImage:[UIImage imageNamed:@"DVD_next_red"] forState:UIControlStateHighlighted];
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventValueChanged];
    
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
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        self.voiceLeft.constant = self.voiceRight.constant = 100;
        self.controlLeft.constant = self.controlRight.constant = 200;
        self.controlBottom.constant = 100;
    }
}

-(void) initSlider
{
    [self.volume setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.volume.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.volume.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    self.rightViewHight.constant = size;
    self.rightViewWidth.constant = size;
}

-(void) changeVolume
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(IBAction)save:(id)sender
{
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
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
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

#pragma mark - UICollectionViewDelegate
-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *collectionCellID = @"collectionCell";
    DVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];

    NSString *imageName = [NSString stringWithFormat:@"%@",self.dvImages[indexPath.row]];
    [cell.btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    cell.btn.tag=indexPath.row;
    [cell.btn addTarget:self action:@selector(control:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(IBAction)control:(id)sender
{
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    UIButton *btn =(UIButton *)sender;
    
    switch (btn.tag) {
        case 0:
            data=[device backward:self.deviceid];
            break;
        case 1:
            btn.selected = !btn.selected;
            if (btn.selected) {
                data=[device play:self.deviceid];
            }else{
                data=[device pause:self.deviceid];
            }
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
        case 6:
            data=[device stop:self.deviceid];
            break;
        case 7:
            data=[device pop:self.deviceid];
            [self poweronAllLighter];
            break;
        case 8:
            data=[device home:self.deviceid];
            break;
        case 9:
            data=[device menu:self.deviceid];
            break;
        case 10:
            data=[device sweepSURE:self.deviceid];
            break;
        case 11:
            data=[device sweepUp:self.deviceid];
            break;
        case 12:
            data=[device sweepLeft:self.deviceid];
            break;
        case 13:
            data=[device sweepDown:self.deviceid];
            break;
        case 14:
            data=[device sweepRight:self.deviceid];
            break;
            
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

@end
