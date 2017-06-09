//
//  IpadFirstViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/5/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "PlaneGraphViewController.h"
#import <AFNetworking.h>

@interface IpadFirstViewController : CustomViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;

@end
