//
//  IphoneNewEditSceneController.h
//  SmartHome
//
//  Created by zhaona on 2017/3/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneNewEditSceneController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,assign) int sceneID;
@property(nonatomic,assign) int roomID;
@end
