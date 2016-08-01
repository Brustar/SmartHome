//
//  ProfireListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfireListController;

@protocol ProfireListControllerDelegate <NSObject>

-(void)ProfireListController:(ProfireListController *)centerListVC selected:(NSInteger)row;

@end

@interface ProfireListController : UIViewController@property (nonatomic,weak) id<ProfireListControllerDelegate> delegate;

@end
