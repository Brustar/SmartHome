//
//  TouchSubViewController.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneAddSceneController.h"

@protocol TouchSubViewDelegate <NSObject>

@optional

-(void)removeSecene;
-(void)collectSecene;
-(void)colseSecene;

@end

@interface TouchSubViewController : UIViewController

@property (weak,nonatomic)id<TouchSubViewDelegate>delegate;

- (instancetype)initWithTitle:(NSString *)title;

@end
