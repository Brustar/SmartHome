//
//  IpadSceneViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/5/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneRoomView.h"
#import "CustomViewController.h"
#import "AFNetworkReachabilityManager.h"

@interface IpadSceneViewController : CustomViewController
@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (nonatomic,assign) int roomID;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;

@end
