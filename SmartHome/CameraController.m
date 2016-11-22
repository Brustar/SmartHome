//
//  CameraController.m
//  SmartHome
//
//  Created by Brustar on 16/6/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CameraController.h"
#import "SQLManager.h"
#import "SceneCell.h"
#import "Camera.h"
#import "SceneManager.h"

#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)
#define CELL_WIDTH self.collectionView.frame.size.width / 2.0 - 10
#define CELL_HEIGHT self.collectionView.frame.size.height / 2.0 - 10
#define MINSPACE 20
#define BIG_WIDTH  self.collectionView.frame.size.width
#define BIG_HEIGTH self.collectionView.frame.size.height

@interface CameraController ()<UICollectionViewDelegate,UICollectionViewDataSource>
//@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) NSTimer *nextFrameTimer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *cameraIds;
@property (nonatomic,strong) NSMutableArray *camerUrls;
@property (nonatomic,strong) SceneCell *cell;
@property (nonatomic,assign) int index;
@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation CameraController


-(NSMutableArray *)cameraIds
{
    if(!_cameraIds)
    {
        _cameraIds = [NSMutableArray array];
        if(self.sceneid > 0 && !_isAddDevice)
        {
            NSArray *camera = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            [_cameraIds addObjectsFromArray:camera];
        }else if(self.roomID)
        {
            [_cameraIds addObjectsFromArray:[SQLManager getDeviceByTypeName:@"摄像头" andRoomID:self.roomID]];
        }else{
            [_cameraIds addObject: self.deviceid];
        }
            }
    return _cameraIds;
}


- (void)viewWillAppear:(BOOL)animated
{
    /*
    _video = [[RTSPPlayer alloc] initWithVideo:self.camerUrls[self.index] usesTcp:YES];
    _video.outputWidth =  CELL_WIDTH;
    _video.outputHeight = CELL_HEIGHT;
    */
    NSLog(@"video duration: %f",_video.duration);
    NSLog(@"video size: %d x %d", _video.sourceWidth, _video.sourceHeight);
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"监控";
    
    self.camerUrls = [NSMutableArray array];
    for(int i = 0; i < self.cameraIds.count; i++)
    {
        NSString *url = [SQLManager deviceUrlByDeviceID:[self.cameraIds[i] intValue]];
        [self.camerUrls addObject:url];
    }

    if ([[DeviceInfo defaultManager] editingScene]) {
        NSArray *IDS = [SQLManager getDeviceByTypeName:@"摄像头" andRoomID:self.roomID];
        self.deviceid = IDS[0];
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        [self save:nil];
    }
}

-(IBAction)save:(id)sender
{
    Camera *device=[[Camera alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}
/*
-(IBAction)playButtonAction:(id)sender {
       _lastFrameTime = -1;
    
    
    [_video seekTime:0.0];
    
    [_nextFrameTimer invalidate];
    _nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}

-(void)displayNextFrame:(NSTimer *)timer
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![_video stepFrame]) {
        [timer invalidate];
        [_video closeAudio];
        return;
    }
    self.cell.imgView.image = _video.currentImage;
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (_lastFrameTime<0) {
        _lastFrameTime = frameTime;
    } else {
        _lastFrameTime = LERP(frameTime, _lastFrameTime, 0.8);
    }
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - UICollectionDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    self.cell = cell;
    self.index = (int)indexPath.row;
    cell.imgView.userInteractionEnabled = YES;
    //[self playButtonAction:nil];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CELL_WIDTH , CELL_HEIGHT);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return MINSPACE;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return MINSPACE;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:self.collectionView.frame];
    self.imageView = bgView;
    [self.view addSubview:bgView];
    bgView.image = self.cell.imgView.image;
    bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeView)];
    [bgView addGestureRecognizer:tapGesture];
    [self shakeToShow:bgView];
}

-(void)closeView{
    [self.imageView removeFromSuperview];
    
}
- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}
@end
