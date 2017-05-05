//
//  PhotoGraphViewConteoller.h
//  SmartHome
//
//  Created by zhaona on 2017/5/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@class PhotoGraphViewConteoller;
@protocol PhotoGraphViewConteollerDelegate <NSObject>

-(void)PhotoIconController:(PhotoGraphViewConteoller *)iconVC withImgName:(NSString *)imgName;

@end
@interface PhotoGraphViewConteoller : CustomViewController

@property(nonatomic,weak)id<PhotoGraphViewConteollerDelegate> delegate;

@end
