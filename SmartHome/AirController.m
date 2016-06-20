//
//  AirController.m
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//
static long kECAirSliderTag = 100;
#import "AirController.h"
#import "SceneManager.h"
#import "Aircon.h"

@interface AirController ()
@property (weak, nonatomic) IBOutlet UIView *thermometerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *modeViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *modeViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *showTemLabel;

@end

@implementation AirController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modeViewWidth.constant = 320;
    self.modeViewHeight.constant = self.modeViewWidth.constant;
    
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Aircon class]]) {
                
                self.showTemLabel.text = [NSString stringWithFormat:@"%d°C", ((Aircon*)[scene.devices objectAtIndex:i]).temperature];
            }
        }
    }

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self buildThermometer];
    [self loadAirConditionHistory];
    
    
}

//设置空调温度刻度尺
-(void)buildThermometer
{
    for (UIView *sub in _thermometerView.subviews) {
        [sub removeFromSuperview];
    }
    _thermometerView.backgroundColor = [UIColor clearColor];
    CGFloat widthShort = 30;
    CGFloat widthLong = 40;
    CGFloat widthSlider = 46;
    CGFloat lineHeight = 3;
    CGFloat sliderHeight = 7;
    
    int spaceCount = 43 - 18;
    CGFloat space = (_thermometerView.bounds.size.height - (spaceCount+1) * lineHeight) / spaceCount;
    
    CGFloat oriX = _thermometerView.bounds.size.width - widthShort;
    CGFloat oriY = 0;
    CGFloat lineWidth = widthShort;
    NSString *lineImage = @"air_line_short";
    for (int i = 43; i > 17; i--) {
        if (i % 5 == 0) {
            lineWidth = widthLong;
            lineImage = @"air_line_long";
        }
        else {
            lineWidth = widthShort;
            lineImage = @"air_line_short";
        }
        oriX = _thermometerView.bounds.size.width - lineWidth;
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(oriX, oriY, lineWidth, lineHeight)];
        line.userInteractionEnabled = YES;
        line.tag = i;
        line.image = [UIImage imageNamed:lineImage];

        [_thermometerView addSubview:line];
        
        oriY += line.bounds.size.height + space;
    }
    
    UIView *view = [_thermometerView viewWithTag:30];
    CGFloat sliderY = view.center.y - sliderHeight/2;
    CGFloat sliderX = _thermometerView.bounds.size.width - widthSlider;
    UIImageView *slider = [[UIImageView alloc] initWithFrame:CGRectMake(sliderX, sliderY, widthSlider, sliderHeight)];
    slider.tag = kECAirSliderTag;
    slider.image = [UIImage imageNamed:@"air_line_slider"];
    [_thermometerView addSubview:slider];
}
//获取空调的状态
- (void)loadAirConditionHistory {
    unsigned int temperature = [self.showTemLabel.text intValue];
   [self setTemperature:temperature];
    
}
- (void)setTemperature:(unsigned int)temperature {
    self.showTemLabel.text= [NSString stringWithFormat:@"%d℃", temperature];
    
    UIView *slider = [_thermometerView viewWithTag:kECAirSliderTag];
    if (temperature >= 18 && temperature <= 43) {
        CGFloat centerY = (43.0f-temperature)/(43.0f-18.0f) * _thermometerView.bounds.size.height;
        slider.center = CGPointMake(slider.center.x, centerY);
        
        
    }
    else {
        slider.hidden = YES;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    [self.thermometerView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.thermometerView addGestureRecognizer:pan];
}
- (void)tap:(UITapGestureRecognizer *)tapGesture {
    UIView *slider = [_thermometerView viewWithTag:kECAirSliderTag];
    slider.hidden = NO;
    CGPoint point = [tapGesture locationInView:_thermometerView];
    CGFloat centerY = point.y;
    slider.center = CGPointMake(slider.center.x, centerY);
    
    [self updateShow:YES];
}
- (void)updateShow:(BOOL)isSetTemperatureRightNow {
    UIView *slider = [_thermometerView viewWithTag:kECAirSliderTag];
    CGFloat centerY = slider.center.y;
    unsigned int curTemperature = (int)43 - (43 - 18) * (centerY / _thermometerView.bounds.size.height);
    self.showTemLabel.text = [NSString stringWithFormat:@"%d℃", curTemperature];
    [self save:nil];
    
}

- (void)pan:(UIPanGestureRecognizer *)panGesture {
    UIView *slider = [self.thermometerView viewWithTag:kECAirSliderTag];
    slider.hidden = NO;
    CGPoint point = [panGesture locationInView:self.thermometerView];
    CGFloat centerY = point.y;
    centerY = centerY < 0 ? 0 : centerY;
    centerY = centerY > self.thermometerView.bounds.size.height ? self.thermometerView.bounds.size.height : centerY;
    slider.center = CGPointMake(slider.center.x, centerY);
    
    BOOL isSetTemperatureRightNow = NO;
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        isSetTemperatureRightNow = YES;
    }
    [self updateShow:isSetTemperatureRightNow];
}


-(IBAction)save:(id)sender
{
    Aircon *device = [[Aircon alloc]init];
    [device setDeviceID:[self.deviceid intValue]];
    
    [device setTemperature:[self.showTemLabel.text intValue]];
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device id:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:@"" withPic:@""];
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


@end
