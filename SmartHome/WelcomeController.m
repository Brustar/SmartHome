//
//  WelcomeController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "WelcomeController.h"
#import "DeviceInfo.h"
#import "SQLManager.h"
#import "AudioManager.h"


@interface WelcomeController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *knowView;

@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *IpadRegisterBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIButton *RegistBtn;

@end

@implementation WelcomeController
{
    NSArray *_imageNames;
    NSArray *_titles;
    
    NSTimer *_timer;
    CGFloat _AutoScrollDelay;
    BOOL _isAutoScroll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    
    [tap addTarget:self action:@selector(tap:)];
    
    self.RegistBtn.enabled = NO;

    [self.view addGestureRecognizer:tap];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
//    self.view.frame = [[UIScreen mainScreen] bounds];
    
    }

-(void)tap:(UITapGestureRecognizer *)tt
{
    
    self.registerView.hidden = YES;
    self.coverView.hidden = YES;
}
- (IBAction)clickWeKnowBtn:(id)sender {
    
    self.coverView.hidden = YES;
    self.knowView.hidden = YES;
}

- (IBAction)clickloginBtn:(id)sender {
}

- (IBAction)demo:(id)sender {
    DeviceInfo *info=[DeviceInfo defaultManager];
    info.db=@"demoDB";
    [SQLManager initDemoSQlite];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self performSegueWithIdentifier:@"iphoneMainSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"gotoMainController" sender:self];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self viewDidLayoutSubviews];
}

-(void)viewDidLayoutSubviews
{
    CGSize scrollSize = CGSizeMake(3 * _pageScrollView.bounds.size.width, _pageScrollView.bounds.size.height);
    if (!CGSizeEqualToSize(_pageScrollView.contentSize, scrollSize)) {
        _pageScrollView.contentSize = scrollSize;
    }
}
- (IBAction)IpadRegisterBtn:(id)sender {
    
    self.coverView.hidden = NO;
    self.registerView.hidden = NO;
    
}
-(void)commonInit
{
    if (!_imageNames) {
        _AutoScrollDelay = 2.0;
        _imageNames =  [NSMutableArray arrayWithObjects:@"u8",@"u0",@"u2", nil];
        for (int i=0; i < [_imageNames count];i++) {
            NSString *imageName = [_imageNames objectAtIndex:i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.pageScrollView.frame.size.width, -10, self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height)];
            imageView.image = [UIImage imageNamed:imageName];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = 1+i;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.pageScrollView addSubview:imageView];
        }
        _pageScrollView.contentSize = CGSizeMake(_pageScrollView.frame.size.width * [_imageNames count], _pageScrollView.frame.size.height);
        _pageScrollView.contentSize = CGSizeMake(_pageScrollView.contentSize.width, 0);
        _titles =  [NSMutableArray arrayWithObjects:@"随时",@"随地",@"每一位", nil];
//        _titleLabel.text = [_titles objectAtIndex:0];
        [self setUpTimer];
    }
}

-(void)dealloc
{
    [self removeTimer];
}

- (void)setUpTimer {
    if (!_isAutoScroll) {//用户滑动，非自动滚动
        return;
    }
    if (_AutoScrollDelay < 0.5) return;
    
    _timer = [NSTimer timerWithTimeInterval:_AutoScrollDelay target:self selector:@selector(scorll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (_timer == nil) return;
    [_timer invalidate];
    _timer = nil;
}

- (void)scorll {
    CGFloat contentOffsetX = _pageScrollView.contentOffset.x + _pageScrollView.frame.size.width >= _pageScrollView.contentSize.width ? 0 : _pageScrollView.contentOffset.x + _pageScrollView.frame.size.width;
    [_pageScrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
    
}

#pragma mark scrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self setUpTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = self.pageScrollView.contentOffset.x / self.pageScrollView.frame.size.width;
//    _titleLabel.text = [_titles objectAtIndex:index];
    _pageControl.currentPage = index;
}

@end
