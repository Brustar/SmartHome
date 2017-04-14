//
//  IphoneNewAddSceneTimerVC.m
//  SmartHome
//
//  Created by zhaona on 2017/4/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneNewAddSceneTimerVC.h"
#import "EFCircularSlider.h"

@interface IphoneNewAddSceneTimerVC ()

@end

@implementation IphoneNewAddSceneTimerVC
{
    EFCircularSlider* minuteSlider;
    EFCircularSlider* hourSlider;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    CGRect minuteSliderFrame = CGRectMake(65, 260, 190, 190);
    minuteSlider = [[EFCircularSlider alloc] initWithFrame:minuteSliderFrame];
    //    minuteSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
    minuteSlider.unfilledColor = [UIColor clearColor];
    minuteSlider.filledColor = [UIColor colorWithRed:87/255.0f green:88/255.0f blue:89/255.0f alpha:0.6f];
    [minuteSlider setInnerMarkingLabels:@[@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",@"11",@"12"]];
    minuteSlider.labelFont = [UIFont systemFontOfSize:8.0f];
    minuteSlider.lineWidth = 20;
    minuteSlider.minimumValue = 0;
    minuteSlider.maximumValue = 24;
    //    minuteSlider.labelColor = [UIColor colorWithRed:76/255.0f green:111/255.0f blue:137/255.0f alpha:1.0f];
    minuteSlider.labelColor = [UIColor lightGrayColor];
    minuteSlider.handleType = semiTransparentWhiteCircle;
    minuteSlider.handleColor = [UIColor clearColor];
    [self.view addSubview:minuteSlider];
//    self.DrawView.backgroundColor = [UIColor redColor];
    //    [imageView addSubview:minuteSlider];
    [minuteSlider addTarget:self action:@selector(minuteDidChange:) forControlEvents:UIControlEventValueChanged];
}
-(void)minuteDidChange:(EFCircularSlider*)slider {
    //    int newVal = (int)slider.currentValue < 60 ? (int)slider.currentValue : 0;
    int newVal = (int)slider.currentValue;
    NSString* oldTime = _starTimeLabel.text;
    NSRange colonRange = [oldTime rangeOfString:@":"];
    //    _timeLabel.text = [NSString stringWithFormat:@"%@:%02d", [oldTime substringToIndex:colonRange.location], newVal];
    _starTimeLabel.text = [NSString stringWithFormat:@"%d:%@", newVal, [oldTime substringFromIndex:colonRange.location + 1]];
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
