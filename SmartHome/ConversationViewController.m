//
//  ConversationViewController.m
//  IM Demo
//
//  Created by Brustar on 2017/3/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ConversationViewController.h"

@interface ConversationViewController ()

@end

@implementation ConversationViewController
@synthesize m_viewNaviBar = _viewNaviBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNaviBar];
    // Do any additional setup after loading the view.
    //设置需要显示哪些类型的会话
    
}

- (void)setupNaviBar {
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width, [CustomNaviBarView barSize].height)];
    _viewNaviBar.m_viewCtrlParent = self;
    [self setNaviBarTitle:self.title];
    [self.view addSubview:_viewNaviBar];
}

- (void)setNaviBarTitle:(NSString *)strTitle
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitle:strTitle];
    }else{APP_ASSERT_STOP}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RCIM sharedRCIM] logout];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
