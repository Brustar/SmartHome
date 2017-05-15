//
//  SceneShortcutsViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "SceneShortcutsViewController.h"

@interface SceneShortcutsViewController ()

@end

@implementation SceneShortcutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initDataSource];
}

- (void)setupNaviBar {
    [self setNaviBarTitle:@"场景快捷键"];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(saveBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (UIView *)setupTableHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 100)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    UILabel *tips1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, UI_SCREEN_WIDTH-100, 20)];
    tips1.textColor = [UIColor lightGrayColor];
    tips1.font = [UIFont systemFontOfSize:15.0];
    tips1.textAlignment = NSTextAlignmentCenter;
    tips1.text = @"在下方选择你需要添加到首页的场景";
    UILabel *tips2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 55, UI_SCREEN_WIDTH-100, 20)];
    tips2.textColor = [UIColor lightGrayColor];
    tips2.font = [UIFont systemFontOfSize:15.0];
    tips2.textAlignment = NSTextAlignmentCenter;
    tips2.text = @"最多可以选择三个场景";
    [header addSubview:tips1];
    [header addSubview:tips2];
    
    return header;
}

- (void)initDataSource {
    _shortcutsArray = [NSMutableArray array];
    _nonShortcutsArray = [NSMutableArray array];
    [self getScenesFromPlist];
}

- (void)getScenesFromPlist {
    NSString *shortcutsPath = [[IOManager sceneShortcutsPath] stringByAppendingPathComponent:@"sceneShortcuts.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:shortcutsPath];
    if (dictionary) {
        NSArray *scenesArray = dictionary[@"Scenes"];
        if (scenesArray && [scenesArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *scene in scenesArray) {
                if ([scene isKindOfClass:[NSDictionary class]]) {
                    Scene *info = [[Scene alloc] init];
                    info.sceneID = [scene[@"sceneID"] intValue];
                    info.sceneName = scene[@"sceneName"];
                    info.roomID = [scene[@"roomID"] integerValue];
                    info.roomName = scene[@"roomName"];
                    
                    [_shortcutsArray addObject:info];
                }
            }
        }
        
        
      //读非快捷键plist
        NSString *nonShortcutsPath = [[IOManager sceneNonShortcutsPath] stringByAppendingPathComponent:@"sceneNonShortcuts.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:nonShortcutsPath];
        if (dict) {
            NSArray *scenesArray = dict[@"Scenes"];
            if (scenesArray && [scenesArray isKindOfClass:[NSArray class]]) {
                for (NSDictionary *scene in scenesArray) {
                    if ([scene isKindOfClass:[NSDictionary class]]) {
                        Scene *info = [[Scene alloc] init];
                        info.sceneID = [scene[@"sceneID"] intValue];
                        info.sceneName = scene[@"sceneName"];
                        info.roomID = [scene[@"roomID"] integerValue];
                        info.roomName = scene[@"roomName"];
                        
                        [_nonShortcutsArray addObject:info];
                    }
                }
            }
        }
        
    }else {
        NSArray *allSceneArray = [SQLManager getAllSceneOrderByRoomID]; //无plist，直接读场景表
        if (allSceneArray.count >0) {
            [_nonShortcutsArray addObjectsFromArray:allSceneArray];
        }
    }
    
    [_shortcutsTableView reloadData];
}

- (void)initUI {
    [self setupNaviBar];
    _shortcutsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _shortcutsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _shortcutsTableView.tableHeaderView = [self setupTableHeader];
}

- (void)fetchSceneShortcuts {
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/scence_shortcut_list.aspx", [IOManager httpAddr]];
    
    
    if (auothorToken.length >0 ) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(2)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

- (void)saveBtnClicked:(UIButton *)btn {
    BOOL result = NO;
    
    //保存至plist
    NSString *shortcutsPath = [[IOManager sceneShortcutsPath] stringByAppendingPathComponent:@"sceneShortcuts.plist"];
    if (_shortcutsArray) {
        NSMutableArray *array = [NSMutableArray array];
        [_shortcutsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            Scene *scene = (Scene *)obj;
            NSMutableDictionary *dicObj = [NSMutableDictionary dictionary];
            [dicObj setObject:@(scene.sceneID) forKey:@"sceneID"];
            [dicObj setObject:scene.sceneName forKey:@"sceneName"];
            [dicObj setObject:@(scene.roomID) forKey:@"roomID"];
            [dicObj setObject:scene.roomName forKey:@"roomName"];
            [array addObject:dicObj];
            
        }];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:array forKey:@"Scenes"];
        result = [dict writeToFile:shortcutsPath atomically:YES];
    }
    
    NSString *nonShortcutsPath = [[IOManager sceneNonShortcutsPath] stringByAppendingPathComponent:@"sceneNonShortcuts.plist"];
    if (_nonShortcutsArray) {
        NSMutableArray *array = [NSMutableArray array];
        [_nonShortcutsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            Scene *scene = (Scene *)obj;
           NSMutableDictionary *dicObj = [NSMutableDictionary dictionary];
            [dicObj setObject:@(scene.sceneID) forKey:@"sceneID"];
            [dicObj setObject:scene.sceneName forKey:@"sceneName"];
            [dicObj setObject:@(scene.roomID) forKey:@"roomID"];
            [dicObj setObject:scene.roomName forKey:@"roomName"];
            [array addObject:dicObj];
        
        }];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:array forKey:@"Scenes"];
        result = [dict writeToFile:nonShortcutsPath atomically:YES];
    }
    
    if (result) {
        [MBProgressHUD showSuccess:@"设置成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [MBProgressHUD showError:@"设置失败"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        if ([responseObject[@"result"] intValue] == 0) {
            
            //场景快捷键
            NSArray *shortcuts = responseObject[@"shortcut_scence_list"];
            if ([shortcuts isKindOfClass:[NSArray class]]) {
                for (NSDictionary *shortcut in shortcuts) {
                    if ([shortcut isKindOfClass:[NSDictionary class]]) {
                        Scene *info = [[Scene alloc] init];
                        info.sceneID =  [shortcut[@"scence_id"] intValue];
                        info.sceneName = shortcut[@"scence_name"];
                        info.roomName = shortcut[@"room_name"];
                        [_shortcutsArray addObject:info];
                    }
                    
                }
            }
            
            //非场景快捷键
            NSArray *nonShortcuts = responseObject[@"room_scence_list"];
            if ([nonShortcuts isKindOfClass:[NSArray class]]) {
                for (NSDictionary *nonShortcut in nonShortcuts) {
                    if ([nonShortcut isKindOfClass:[NSDictionary class]]) {
                        Scene *info = [[Scene alloc] init];
                        info.sceneID =  [nonShortcut[@"scence_id"] intValue];
                        info.sceneName = nonShortcut[@"scence_name"];
                        info.roomName = nonShortcut[@"room_name"];
                        [_nonShortcutsArray addObject:info];
                    }
                    
                }
            }
            
            
            [_shortcutsTableView reloadData];
            
            
        }
    }
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _shortcutsArray.count;
    }else {
        return _nonShortcutsArray.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 50.0)];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 100, 20)];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor lightGrayColor];
    title.font = [UIFont systemFontOfSize:16.0];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.2)];
    line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    [view addSubview:line];
    [view addSubview:title];
    
    if (section == 0) {
        title.text = @"已添加";
    }else {
        title.text = @"可添加";
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"shortcutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        Scene *info = _shortcutsArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", info.roomName,info.sceneName];
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(0, 0, 20, 20);
        [deleteBtn setImage:[UIImage imageNamed:@"key_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = indexPath.row;
        cell.accessoryView = deleteBtn;
    }else {
        Scene *info = _nonShortcutsArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", info.roomName,info.sceneName];
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(0, 0, 20, 20);
        [addBtn setImage:[UIImage imageNamed:@"key_add"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.tag = indexPath.row;
        cell.accessoryView = addBtn;
    }
    
    return cell;
}

- (void)deleteBtnClicked:(UIButton *)btn {
    NSInteger index = btn.tag;
    Scene *info = _shortcutsArray[index];
    Scene *deletedShortcut = [Scene new];
    deletedShortcut.sceneID = info.sceneID;
    deletedShortcut.sceneName = info.sceneName;
    deletedShortcut.roomName = info.roomName;
    [_nonShortcutsArray addObject:deletedShortcut];
    [_shortcutsArray removeObjectAtIndex:index];
    [_shortcutsTableView reloadData];
}

- (void)addBtnClicked:(UIButton *)btn {
    if (_shortcutsArray.count >= 3) {
        [MBProgressHUD showError:@"最多加3个快捷键"];
    }else {
        NSInteger index = btn.tag;
        Scene *info = _nonShortcutsArray[index];
        Scene *addedShortcut = [Scene new];
        addedShortcut.sceneID = info.sceneID;
        addedShortcut.sceneName = info.sceneName;
        addedShortcut.roomName = info.roomName;
        [_shortcutsArray addObject:addedShortcut];
        [_nonShortcutsArray removeObjectAtIndex:index];
        [_shortcutsTableView reloadData];
    }
}

@end
