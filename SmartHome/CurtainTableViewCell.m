//
//  CurtainTableViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "CurtainTableViewCell.h"
#import "SocketManager.h"
#import "SceneManager.h"


@interface CurtainTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderWidthConstraint;

@end
@implementation CurtainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.sliderWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width *0.3;
        
    }
//    self = [[[NSBundle mainBundle] loadNibNamed:@"CurtainTableViewCell" owner:self options:nil] lastObject];
    self.slider.continuous = NO;
    [self.slider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.open addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.close addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [self.slider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.slider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.slider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}


-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.slider]) {
        NSData *data=[[DeviceInfo defaultManager] roll:self.slider.value * 100 deviceID:self.deviceId];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
    }if ([sender isEqual:self.open]) {
        self.slider.value=1;
        NSData *data=[[DeviceInfo defaultManager] open:self.deviceId];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        self.valueLabel.text = @"100%";
        
    }if ([sender isEqual:self.close]) {
        self.slider.value=0;
        NSData *data=[[DeviceInfo defaultManager] close:self.deviceId];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        self.valueLabel.text = @"0%";
    }
    Curtain *device=[[Curtain alloc] init];
    [device setDeviceID:[self.deviceId intValue]];
    [device setOpenvalue:self.slider.value * 100];
    
    if ([sender isEqual:self.open]) {
        [device setOpenvalue:100];
    }
    
    if ([sender isEqual:self.close]) {
        [device setOpenvalue:0];
    }
}


- (IBAction)brightValueChanged:(id)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f%%",self.slider.value *100];
    if([self.open isSelected])
    {
        self.valueLabel.text = @"100%";
        
    }
    if([self.close isSelected])
    {
        self.valueLabel.text = @"0%";
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
