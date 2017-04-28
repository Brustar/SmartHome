//
//  SceneShortcutsViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SQLManager.h"
#import "IOManager.h"

@interface SceneShortcutsViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *shortcutsTableView;
@property (nonatomic, strong) NSMutableArray *shortcutsArray;
@property (nonatomic, strong) NSMutableArray *nonShortcutsArray;
@property (nonatomic, strong) UIButton * naviRightBtn;

@end
