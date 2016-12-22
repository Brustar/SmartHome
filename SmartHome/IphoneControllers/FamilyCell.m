//
//  FamilyCell.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FamilyCell.h"

@interface FamilyCell ()

@end


@implementation FamilyCell


-(void)awakeFromNib{
    [super awakeFromNib];
    self.layer.masksToBounds = YES;
    self.supImageView.layer.cornerRadius = self.supImageView.bounds.size.width / 2.0;
    self.subImageView.layer.cornerRadius = self.subImageView.bounds.size.width /2.0;
    self.lightImageVIew.layer.cornerRadius = self.lightImageVIew.bounds.size.width /2.0;
    self.curtainImageView.layer.cornerRadius = self.curtainImageView.bounds.size.width / 2.0;
    self.airImageVIew.layer.cornerRadius = self.airImageVIew.bounds.size.width / 2.0;
    self.DVDImageView.layer.cornerRadius = self.DVDImageView.bounds.size.width / 2.0;
    self.TVImageView.layer.cornerRadius = self.TVImageView.bounds.size.width / 2.0;
    self.musicImageVIew.layer.cornerRadius = self.musicImageVIew.bounds.size.width / 2.0;
    
    [self.tempLabel setFont:[UIFont systemFontOfSize:18]];
    [self.humidityLabel setFont:[UIFont systemFontOfSize:18]];
    [self.nameLabel setFont:[UIFont systemFontOfSize:14]];
}
-(void)setModel:(IPhoneRoom *)iphoneRom{
    self.nameLabel.text = iphoneRom.roomName;
    self.tag = iphoneRom.roomId;
    
    if (iphoneRom.light) {
        self.lightImageVIew.hidden = NO;
    }else{
        self.lightImageVIew.hidden = YES;
    }
    if (iphoneRom.curtain) {
        self.curtainImageView.hidden = NO;
    }else{
        self.curtainImageView.hidden = YES;
    }
    if (iphoneRom.aircondition) {
        self.airImageVIew.hidden = NO;
    }else
    {
    
        self.airImageVIew.hidden = YES;
    }
    if (iphoneRom.bgmusic) {
        self.musicImageVIew.hidden = NO;
    }else{
        
        self.musicImageVIew.hidden = YES;
    }
    if (iphoneRom.dvd) {
        self.DVDImageView.hidden = NO;
    }else{
        self.DVDImageView.hidden = YES;
    }
    if (iphoneRom.tv) {
        self.TVImageView.hidden = NO;
    }else{
        self.TVImageView.hidden = YES;
    }
        
}


@end
