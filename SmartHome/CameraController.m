//
//  CameraController.m
//  SmartHome
//
//  Created by Brustar on 16/6/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CameraController.h"

#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)

@interface CameraController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) NSTimer *nextFrameTimer;
@end

@implementation CameraController

- (void)viewWillAppear:(BOOL)animated
{
    
        _video = [[RTSPPlayer alloc] initWithVideo:@"rtsp://admin:66396639@192.168.199.248" usesTcp:NO];
        //_video = [[RTSPPlayer alloc] initWithVideo:@"rtsp://admin:abc123456789@192.168.199.108" usesTcp:NO];
        _video.outputWidth = 426;
        _video.outputHeight = 320;
    
        NSLog(@"video duration: %f",_video.duration);
        NSLog(@"video size: %d x %d", _video.sourceWidth, _video.sourceHeight);

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_imgView setContentMode:UIViewContentModeScaleAspectFit];
    [self playButtonAction:nil];
}

-(IBAction)playButtonAction:(id)sender {
    _lastFrameTime = -1;
    
    // seek to 0.0 seconds
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
    _imgView.image = _video.currentImage;
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (_lastFrameTime<0) {
        _lastFrameTime = frameTime;
    } else {
        _lastFrameTime = LERP(frameTime, _lastFrameTime, 0.8);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
