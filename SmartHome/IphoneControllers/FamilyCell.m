//
//  FamilyCell.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FamilyCell.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SceneManager.h"

@interface FamilyCell ()<TcpRecvDelegate>

@end


@implementation FamilyCell


-(void)awakeFromNib{
    [super awakeFromNib];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    
    self.layer.masksToBounds = YES;
    self.supImageView.layer.cornerRadius = self.supImageView.bounds.size.width / 2.0;
    self.subImageView.layer.cornerRadius = self.subImageView.bounds.size.width /2.0;
    self.lightImageVIew.layer.cornerRadius = self.lightImageVIew.bounds.size.width /2.0;
    self.curtainImageView.layer.cornerRadius = self.curtainImageView.bounds.size.width / 2.0;
    self.airImageVIew.layer.cornerRadius = self.airImageVIew.bounds.size.width / 2.0;
    self.DVDImageView.layer.cornerRadius = self.DVDImageView.bounds.size.width / 2.0;
    self.TVImageView.layer.cornerRadius = self.TVImageView.bounds.size.width / 2.0;
    self.musicImageVIew.layer.cornerRadius = self.musicImageVIew.bounds.size.width / 2.0;

}

-(void)timer:(NSTimer *)timer
{
    SocketManager *sock = [SocketManager defaultManager];
    [sock connectTcp];
    sock.delegate = self;
    DeviceInfo *device =[DeviceInfo defaultManager];
    if (device.connectState == outDoor && device.masterID) {
        NSData *data = [[SceneManager defaultManager] getRealSceneData];
        [sock.socket writeData:data withTimeout:1 tag:1];
        [timer invalidate];
    }
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

#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{

    
    Proto proto = protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state==0x6A) {
            
            self.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.humidityLabel.text = valueString;
        }
    }
}

@end
