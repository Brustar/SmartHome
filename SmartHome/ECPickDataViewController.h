//
//  ECPickDataViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/2/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ECPickDataViewController;
@protocol ECPickDataViewControllerDelegate <NSObject>

-(void)pickDate:(ECPickDataViewController *)pickerVC date:(NSString *)dateStr;

@end
@interface ECPickDataViewController : UIViewController
@property(nonatomic,weak) id<ECPickDataViewControllerDelegate> delegate;

@end
