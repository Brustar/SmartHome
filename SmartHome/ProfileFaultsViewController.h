//
//  ProfieFaultsViewController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <AFNetworking.h>

typedef NS_ENUM(NSUInteger, FAULT_STATUS) {
    UNUPLOAD = 1, //未上传
    UPLOADED,       //已上传
    COMPLETE,       //维修完成
    STILL_FAULT     //未修好
};

#define FAULT_URL @"cloud/breakdown.aspx"

@interface ProfileFaultsViewController : UIViewController
@property(nonatomic,strong) NSMutableArray *Mydefaults;
@end
