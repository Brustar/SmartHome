//
//  CenterListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CenterListController;
@protocol CenterListControllerDelegate <NSObject>

-(void)CenterListController:(CenterListController *)centerListVC selected:(NSInteger)row;

@end
@interface CenterListController : UITableViewController
@property (nonatomic,weak) id<CenterListControllerDelegate> delegate;
@end
