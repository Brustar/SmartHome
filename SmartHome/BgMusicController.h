//
//  BgMusicController.h
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface BgMusicController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;

@end
