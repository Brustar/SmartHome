//
//  ConversationViewController.m
//  IM Demo
//
//  Created by Brustar on 2017/3/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ConversationViewController.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "SQLManager.h"
#import "UIImageView+WebCache.h"
#import "BaseTabBarController.h"

static NSString *const menuCellIdentifier = @"groupCell";
@interface ConversationViewController ()<UITableViewDelegate,UITableViewDataSource,YALContextMenuTableViewDelegate>
@property (nonatomic,strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSMutableArray *menuTitles;
@property (nonatomic, strong) NSMutableArray *menuIcons;
@end

@implementation ConversationViewController
@synthesize m_viewNaviBar = _viewNaviBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNaviBar];
    
    //显示蒙版
    [LoadMaskHelper showMaskWithType:ChatView onView:self.tabBarController.view delay:0.5 delegate:self];
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = YES;
    baseTabbarController.tabBar.hidden = YES;
}

- (void)leftBarButtonItemPressed:(id)sender
{
    [super leftBarButtonItemPressed:sender];
    [[RCIM sharedRCIM] logout];
}

- (void)setupNaviBar {
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width, [CustomNaviBarView barSize].height)];
    
    _viewNaviBar.m_viewCtrlParent = self;
    [self setNaviBarTitle:self.title];
    [self.view addSubview:_viewNaviBar];
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"Contacts" imgHighlight:@"Contacts" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && _isShowInSplitView) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
}

- (void)adjustNaviBarFrameForSplitView {
    _viewNaviBar.frame = Rect(0.0f, 0.0f, [CustomNaviBarView barSizeForSplitView].width, [CustomNaviBarView barSize].height);
}

- (void)adjustTitleFrameForSplitView {
    [_viewNaviBar adjustTitleFrameForSplitView];
}

- (void)setNaviBarRightBtnForSplitView:(UIButton *)btn {
    if (_viewNaviBar)
    {
        [_viewNaviBar setRightBtnForSplitView:btn];
    }else{APP_ASSERT_STOP}
}

- (void)rightBtnClicked:(UIButton *)sender {
    [self initiateMenuOptions];
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.05;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Left;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(20,0,0,0) animated:YES];
}

- (void)setNaviBarTitle:(NSString *)strTitle
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitle:strTitle];
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarRightBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setRightBtn:btn];
    }else{APP_ASSERT_STOP}

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Local methods
- (void)initiateMenuOptions {
    self.menuTitles = [NSMutableArray new];
    self.menuIcons = [[NSMutableArray alloc] init];
    NSArray *s = [SQLManager queryAllChat];
    [self.menuTitles addObject: @""];
    [self.menuIcons addObject: @""];
    for (id user in s) {
        [self.menuTitles addObject: [user objectForKey:@"nickname"] ];
        [self.menuIcons addObject: [[user objectForKey:@"portrait"] description]];
    }
    [self.contextMenuTableView reloadData];
}

#pragma mark - YALContextMenuTableViewDelegate
- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath = %@", indexPath);
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView dismisWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
    
    //if (cell) {
        cell.backgroundColor = [UIColor clearColor];
        cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:[self.menuIcons objectAtIndex:indexPath.row]];
        [cell.menuImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Contacts"] options:SDWebImageRetryFailed];
    //}
    
    return cell;
}

#pragma mark - SingleMaskViewDelegate
- (void)onTransparentBtnClicked:(UIButton *)btn {
    [self initiateMenuOptions];
    // init YALContextMenuTableView tableView
    if (!self.contextMenuTableView) {
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.animationDuration = 0.05;
        //optional - implement custom YALContextMenuTableView custom protocol
        self.contextMenuTableView.yalDelegate = self;
        //optional - implement menu items layout
        self.contextMenuTableView.menuItemsSide = Left;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        UINib *cellNib = [UINib nibWithNibName:@"ContextMenuCell" bundle:nil];
        [self.contextMenuTableView registerNib:cellNib forCellReuseIdentifier:menuCellIdentifier];
    }
    
    // it is better to use this method only for proper animation
    [self.contextMenuTableView showInView:self.view withEdgeInsets:UIEdgeInsetsMake(20,0,0,0) animated:YES];
}

- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
