//
//  FamilyCell.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPhoneRoom.h"

@interface FamilyCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *supImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//房间Name
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lightImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *curtainImageView;//窗帘
@property (weak, nonatomic) IBOutlet UIImageView *DVDImageView;
@property (weak, nonatomic) IBOutlet UIImageView *musicImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *airImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *TVImageView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;//房间温度
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;//房间湿度

-(void)setModel:(IPhoneRoom *)iphoneRom;
@end
