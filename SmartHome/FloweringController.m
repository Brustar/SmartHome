//
//  FloweringController.m
//  SmartHome
//
//  Created by Brustar on 2017/5/4.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FloweringController.h"
#import "HTCircularSlider.h"
#import "DeviceInfo.h"
#import "SocketManager.h"
#import "Schedule.h"
#import "IOManager.h"

@interface FloweringController ()
@property (weak, nonatomic) IBOutlet UILabel *HLabel;
@property (weak, nonatomic) IBOutlet UILabel *SLabel;

@end

@implementation FloweringController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNaviBarTitle:@"智能浇花"];
    [self initSlider];
}

-(void) initSlider
{
    int sliderSize = 90;
    CGRect frame = CGRectInset(self.view.bounds, 0, 0);
    
    HTCircularSlider *slider = [[HTCircularSlider alloc] initWithFrame:frame];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];

    slider.handleImage = [UIImage imageNamed:@"schedule_pointer"];
    
    slider.handleSize = CGPointMake(15/2, 51/2);
    slider.maximumValue = 24;
    slider.value = 0;
    slider.tag = 0;
    slider.radius = sliderSize;
    
    sliderSize = 65;
    frame = CGRectMake(self.view.center.x-sliderSize, self.view.center.y-sliderSize, sliderSize*2, sliderSize*2);
    HTCircularSlider *second = [[HTCircularSlider alloc] initWithFrame:frame];
    [self.view addSubview:second];
    [second addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];
    
    second.handleImage = [UIImage imageNamed:@"schedule_thumb"];
    second.handleSize = CGPointMake(28/2, 27/2);
    
    second.maximumValue = 16;
    second.value = 0;
    second.trackAlpha = 0.6;
    second.tag = 1;
    second.radius = sliderSize;
}


- (void)onValueChange:(HTCircularSlider *)slider {
    NSLog(@"%f", slider.value);
    
    if (slider.tag == 0) {
        float dec = slider.value-(int)slider.value;
        int second = (int)(dec*60);
        NSString *pattern = second>9?@"%d:%d":@"%d:0%d";
        self.HLabel.text = [NSString stringWithFormat:pattern,(int)slider.value,second];
    }else{
        self.SLabel.text = [NSString stringWithFormat:@"%dS",(int)slider.value];
    }
}

- (IBAction)save:(id)sender {
    Schedule *sch = [[Schedule alloc] init];
    sch.deviceID = [self.deviceid intValue];
    sch.startTime = self.HLabel.text;
    sch.interval = [self.SLabel.text intValue];
    [IOManager writeScene:[NSString stringWithFormat:@"schedule_%@.plist",self.deviceid] scene:sch];
}

- (IBAction)start:(id)sender {
    NSData *data = [[DeviceInfo defaultManager] toogle:0x01 deviceID:self.deviceid];
    [[[SocketManager defaultManager] socket] writeData:data withTimeout:1 tag:1];
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
