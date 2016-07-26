//
//  AddScenceController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddScenceController;
@protocol  AddScenceControllerDelegate <NSObject>

-(void)AddScenceControllerDelegate:(AddScenceController *)scenseCV SelectedRoom:(NSInteger)RoomID;

@end
@interface AddScenceController : UITableViewController

@property (nonatomic,weak) id<AddScenceControllerDelegate> delegate;
@end
