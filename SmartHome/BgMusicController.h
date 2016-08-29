//
//  BgMusicController.h
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface BgMusicController : UIViewController

@property (strong, nonatomic) DeviceInfo *beacon;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;

@end
