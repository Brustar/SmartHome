//
//  IphoneFixTimerController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneFixTimerController.h"

@interface IphoneFixTimerController ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *astronomicalHight;
@property (weak, nonatomic) IBOutlet UIButton *astronomicalBut;
@property (weak, nonatomic) IBOutlet UIButton *customTimeBtn;
@property (weak, nonatomic) IBOutlet UIView *astronomicalView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *astronmicalTypes;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTime;
@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray *minutes;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customViewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repeatViewHight;

@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *repeatBtns;

@end

@implementation IphoneFixTimerController
-(NSArray *)hours
{
    if(!_hours)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 24; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            
        }
        _hours = [arr copy];
    }
    return _hours;
}
-(NSArray *)minutes
{
    if(!_minutes)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 60; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            
        }
        _minutes = [arr copy];
        
    }
    return _minutes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.astronomicalHight.constant = 0;
    for(UIButton *btn in self.astronmicalTypes)
    {
        btn.hidden = YES;
    }
    self.customView.hidden = YES;
    self.customViewHight.constant = 0;
    self.repeatViewHight.constant = [[UIScreen mainScreen] bounds].size.width / 7.0;
    for(UIButton *btn in self.repeatBtns)
    {
        btn.layer.cornerRadius = self.repeatViewHight.constant / 2.0;
        btn.layer.masksToBounds = YES;
    }
}
- (IBAction)selectedAstronomicalBtn:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if(btn.selected)
    {
        [self.astronomicalBut setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        //self.customTimeBtn.enabled = NO;
        self.astronomicalHight.constant = 50;
        for(UIButton *btn in self.astronmicalTypes)
        {
            btn.hidden = NO;
        }

    }else{
        [self.astronomicalBut setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateSelected];
        //self.customTimeBtn.enabled = YES;
        self.astronomicalHight.constant = 0;
        for(UIButton *btn in self.astronmicalTypes)
        {
            btn.hidden = YES;
        }

    }
}
- (IBAction)selectedCustomTimeBtn:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if(btn.selected)
    {
        [self.customTimeBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        self.customView.hidden = NO;
        self.customViewHight.constant = 300;
        //self.astronomicalBut.enabled = NO;
    }else{
        [self.customTimeBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateSelected];
        self.customView.hidden = YES;
        self.customViewHight.constant = 0;
    }
    
}
- (IBAction)selectedRepeatTime:(id)sender {
    
    
}

#pragma mark - UIPickerDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return self.hours.count;
    }else
    {
        return self.minutes.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0 )
    {
        return self.hours[row];
    }else{
        return self.minutes[row];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *hour = self.hours[[self.pickerTime selectedRowInComponent:0]];
    NSString *min = self.minutes[[self.pickerTime selectedRowInComponent:1]];
   NSString *time = [NSString stringWithFormat:@"%@:%@", hour, min];
    if (self.startTimeBtn.selected) {
        [self.startTimeBtn setTitle:time forState:UIControlStateNormal];
    } else {
        [self.endTimeBtn setTitle:time forState:UIControlStateNormal];
    }

}
- (IBAction)setTimeOnClick:(id)sender {
    if (sender == self.startTimeBtn)
    {
        if (self.startTimeBtn.selected)
        {
            self.startTimeBtn.selected = NO;
        }
        else {
            self.startTimeBtn.selected = YES;
            self.endTimeBtn.selected = NO;
        }
    }
    else {
        if (self.endTimeBtn.selected) {
            self.endTimeBtn.selected = NO;
        }
        else {
            self.startTimeBtn.selected = NO;
            self.endTimeBtn.selected = YES;
            
            
        }
    }
    

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
