//
//  CustomViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/11.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import "CustomViewController.h"
#import "Utilities.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+Navigator.h"

@interface CustomViewController ()

@end

@implementation CustomViewController
@synthesize m_viewNaviBar = _viewNaviBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width, [CustomNaviBarView barSize].height)];
    _viewNaviBar.m_viewCtrlParent = self;
    [self.view addSubview:_viewNaviBar];
    
    //背景
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]]];
}

- (void)adjustNaviBarFrameForSplitView {
    _viewNaviBar.frame = Rect(0.0f, 0.0f, [CustomNaviBarView barSizeForSplitView].width, [CustomNaviBarView barSize].height);  
}

- (void)adjustTitleFrameForSplitView {
    [_viewNaviBar adjustTitleFrameForSplitView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [Utilities cancelPerformRequestAndNotification:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_viewNaviBar && !_viewNaviBar.hidden)
    {
        [self.view bringSubviewToFront:_viewNaviBar];
    }else{}
}

#pragma mark -

-(void)naviToDevice
{
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [naviBtn setImage:[UIImage imageNamed:@"dir_left"] forState:UIControlStateNormal];
    [[naviBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         [self popToDevice];
     }];
    [self setNaviBarLeftBtn:naviBtn];
}

- (void)bringNaviBarToTopmost
{
    if (_viewNaviBar)
    {
        [self.view bringSubviewToFront:_viewNaviBar];
    }else{}
}

- (void)hideNaviBar:(BOOL)bIsHide
{
    _viewNaviBar.hidden = bIsHide;
}

- (void)showNetStateView {
    [_viewNaviBar showNetStateView];
}

- (void)setNetState:(int)state {
    [_viewNaviBar setNetState:state];
}

- (void)setNaviBarTitle:(NSString *)strTitle
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitle:strTitle];
        self.title = strTitle;
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarLeftBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setLeftBtn:btn];
    }
}

- (void)setNaviBarRightBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setRightBtn:btn];
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarRightBtnForSplitView:(UIButton *)btn {
    if (_viewNaviBar)
    {
        [_viewNaviBar setRightBtnForSplitView:btn];
    }else{APP_ASSERT_STOP}
}



-(void)setNaviMiddletBtn:(UIButton *)btn
{
    if (_viewNaviBar) {
        [_viewNaviBar setMiddleBtn:btn];
    }else{APP_ASSERT_STOP}
}
- (void)naviBarAddCoverView:(UIView *)view
{
    if (_viewNaviBar && view)
    {
        [_viewNaviBar showCoverView:view animation:YES];
    }else{}
}

- (void)naviBarAddCoverViewOnTitleView:(UIView *)view
{
    if (_viewNaviBar && view)
    {
        [_viewNaviBar showCoverViewOnTitleView:view];
    }else{}
}

- (void)naviBarRemoveCoverView:(UIView *)view
{
    if (_viewNaviBar)
    {
        [_viewNaviBar hideCoverView:view];
    }else{}
}

@end
