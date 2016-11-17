//
//  RealScene.h
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "TouchImage.h"
#import "HttpManager.h"
#import "SceneManager.h"
#import "AFHTTPSessionManager.h"
#import "UIImageView+WebCache.h"

//实景控制
@interface RealScene : UIViewController

@property (strong, nonatomic) IBOutlet TouchImage *realimg;

@end
