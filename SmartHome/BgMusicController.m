//
//  BgMusicController.m
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "BgMusicController.h"
#import "VolumeManager.h"
#import "SocketManager.h"

@interface BgMusicController ()
@property (weak, nonatomic) IBOutlet UISlider *volume;


@end

@implementation BgMusicController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.beacon=[[DeviceInfo alloc] init];
    [self.beacon addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:self.beacon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        self.volume.value=[[self.beacon valueForKey:@"volume"] floatValue];
        //[self save:nil];
    }
}

- (IBAction)pause:(id)sender {
    
    
}

-(void)dealloc
{
    [self.beacon removeObserver:self forKeyPath:@"volume" context:nil];
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
