//
//  HostIDSController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HostIDSControllerDelegate;

@interface HostIDSController : UIViewController
@property (nonatomic, assign) id<HostIDSControllerDelegate>delegate;

@end


@protocol HostIDSControllerDelegate <NSObject>

@optional

- (void)didSelectHostID;

@end
