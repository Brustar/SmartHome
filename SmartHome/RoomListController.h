//
//  RoomListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoomListController;
@protocol  RoomListControllerDelegate <NSObject>

-(void)RoomListControllerDelegate:(RoomListController *)roomListCV SelectedRoom:(NSInteger)RoomID;
-(void)showDataPicker;

@end

@interface RoomListController : UIViewController
@property (nonatomic,weak) id<RoomListControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *pickTimeView;
@end
