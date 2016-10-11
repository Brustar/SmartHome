//
//  ProfireListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfileListController;

@protocol ProfileListControllerDelegate <NSObject>

-(void)ProfileListController:(ProfileListController *)centerListVC selected:(NSInteger)row;

@end

@interface ProfileListController : UIViewController@property (nonatomic,weak) id<ProfileListControllerDelegate> delegate;

@end
