//
//  IphoneAddSceneController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FixTimeListCell.h"
#import "CustomViewController.h"

@interface IphoneAddSceneController : CustomViewController
@property (nonatomic,assign) int roomId;
@property(nonatomic,assign) int sceneID;
@property(nonatomic,assign) int deviceID;
//@property(nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isFavor;
@property (nonatomic,strong) FixTimeListCell * cell;
@property (weak, nonatomic) IBOutlet UITableView *subTableView;
@end
