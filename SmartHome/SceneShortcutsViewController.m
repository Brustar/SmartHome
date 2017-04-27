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
    _shortcutsArray = [NSMutableArray array];
    _nonShortcutsArray = [NSMutableArray array];
    [self initUI];
    [self fetchSceneShortcuts];
}

- (void)initUI {
    _shortcutsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _shortcutsTableView.tableFooterView = [UIView new];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"shortcutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0) {
        Scene *info = _shortcutsArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", info.roomName,info.sceneName];
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[UIImage imageNamed:@"key_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag = indexPath.row;
        cell.accessoryView = deleteBtn;
    }else {
        Scene *info = _nonShortcutsArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", info.roomName,info.sceneName];
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
