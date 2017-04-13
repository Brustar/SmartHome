//
//  IphoneLightController.h
//  SmartHome
//
//  Created by zhaona on 2016/11/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IphoneLightController : CustomViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSString * sceneid;

@property(nonatomic, strong) UIButton *_sunShineBtn;
@property(nonatomic, strong) UIButton *_romanticBtn;
@property(nonatomic, strong) UIButton *_silentBtn;
@property(nonatomic, assign) BOOL isEditScene;

@end
