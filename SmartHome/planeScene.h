//
//  planeScene.h
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "TouchImage.h"
#import "HttpManager.h"
#import "AFHTTPSessionManager.h"

//平面图，我的家
@interface planeScene : UIViewController

@property (strong, nonatomic) IBOutlet TouchImage *planeimg;
@property (nonatomic) int deviceID;

@end
