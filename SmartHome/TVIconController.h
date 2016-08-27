//
//  TVIconController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TVIconController;
@protocol TVIconControllerDelegate <NSObject>

-(void)tvIconController:(TVIconController *)iconVC withImgName:(NSString *)imgName;
@end
@interface TVIconController : UIViewController

@property(nonatomic,weak)id<TVIconControllerDelegate> delegate;

@end
