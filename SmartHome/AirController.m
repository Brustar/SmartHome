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
#import "RulerView.h"

@interface AirController ()<RulerViewDatasource, RulerViewDelegate>
@property (weak, nonatomic) IBOutlet RulerView *thermometerView;
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
    self.thermometerView.datasource = self;
    self.thermometerView.delegate = self;
    
    [self.thermometerView updateCurrentValue:24];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.thermometerView reloadView];
}

#pragma mark - RulerViewDelegate

- (void)rulerView:(RulerView *)rulerView didChangedCurrentValue:(CGFloat)currentValue {
    NSInteger value = round(currentValue);
    
    NSString *valueString = [NSString stringWithFormat:@"%d ℃", (int)value];
    
    self.showTemLabel.text = valueString;
}

#pragma mark - RulerViewDatasrouce

#pragma mark - Item setting

- (RulerItemModel *)rulerViewRulerItemModel:(RulerView *)rulerView {
    RulerItemModel *itemModel = [[RulerItemModel alloc] init];
    
    itemModel.itemLineColor = [UIColor blackColor];
    itemModel.itemMaxLineWidth = 30;
    itemModel.itemMinLineWidth = 20;
    itemModel.itemMiddleLineWidth = 24;
    itemModel.itemLineHeight = 1;
    itemModel.itemNumberOfRows = 16;
    itemModel.itemHeight = 60;
    itemModel.itemWidth = itemModel.itemMaxLineWidth;
    
    return itemModel;
}

#pragma mark - Ruler setting

- (CGFloat)rulerViewMaxValue:(RulerView *)rulerView {
    return 32;
}

- (CGFloat)rulerViewMinValue:(RulerView *)rulerView {
    return 16;
}

- (UIFont *)rulerViewTextLabelFont:(RulerView *)rulerView {
    return [UIFont systemFontOfSize:11.f];
}

- (UIColor *)rulerViewTextLabelColor:(RulerView *)rulerView {
    return [UIColor magentaColor];
}

- (CGFloat)rulerViewTextlabelLeftMargin:(RulerView *)rulerView {
    return 4.f;
}

- (CGFloat)rulerViewItemScrollViewDecelerationRate:(RulerView *)rulerView {
    return 0;
}

#pragma mark - Left tag setting

- (CGFloat)rulerViewLeftTagLineWidth:(RulerView *)rulerView {
    return 50;
}

- (CGFloat)rulerViewLeftTagLineHeight:(RulerView *)rulerView {
    return 2;
}

- (UIColor *)rulerViewLeftTagLineColor:(RulerView *)rulerView {
    return [UIColor redColor];
}

- (CGFloat)rulerViewLeftTagTopMargin:(RulerView *)rulerView {
    return 300;
}


@end
