//
//  IphoneRoomListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@class IphoneRoomListController;
@protocol IphoneRoomListDelegate<NSObject>

-(void)iphoneRoomListController:(IphoneRoomListController *)vc withRoomName:(NSString *)roomName;

@end
@interface IphoneRoomListController : CustomViewController

@property (nonatomic,weak) id<IphoneRoomListDelegate> delegate;
@end
