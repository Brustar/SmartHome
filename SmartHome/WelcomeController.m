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
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "CryptoManager.h"
#import "RegisterPhoneNumController.h"
#import "SunCount.h"
#import <CoreLocation/CoreLocation.h>
#import "PackManager.h"

@interface WelcomeController ()<QRCodeReaderDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIPageViewControllerDelegate,NSLayoutManagerDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *knowView;
@property(nonatomic,strong) NSString *role;
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property(nonatomic,strong) NSString *masterId;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *IpadRegisterBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIButton *RegistBtn;
@property (weak, nonatomic) IBOutlet UIButton *LoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *iphoneBtn;//体验按钮
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;
@property (nonatomic,strong) NSArray *antronomicalTimes;
@property (strong,nonatomic) CLLocationManager *lm;

@end

@implementation WelcomeController
{
    NSArray *_imageNames;
    NSTimer *_timer;
    CGFloat _AutoScrollDelay;
    BOOL _isAutoScroll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    
    [tap addTarget:self action:@selector(tap:)];
    
    self.RegistBtn.enabled = NO;
    self.knowView.hidden = YES;
    self.coverView.hidden = YES;
    [self.view addGestureRecognizer:tap];
    self.pageScrollView.delegate = self;
    _LoginBtn.layer.cornerRadius = 5.0f; //圆角半径
    _LoginBtn.layer.masksToBounds = YES; //圆角
    _iphoneBtn.layer.cornerRadius = 5.0f; //圆角半径
    _iphoneBtn.layer.masksToBounds = YES; //圆角
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
    
//    self.coverView.hidden = YES;
//    self.knowView.hidden = YES;
}

- (IBAction)clickloginBtn:(id)sender {
}

- (IBAction)demo:(id)sender {
    DeviceInfo *info=[DeviceInfo defaultManager];
        info.db=@"demoDB";
        info.masterID = 255l;
    
    [DeviceInfo defaultManager].masterID = 255l;
    
    [[NSUserDefaults standardUserDefaults] objectForKey:@"HostID"];
    [SQLManager initDemoSQlite];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self performSegueWithIdentifier:@"iphoneMainSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"gotoMainController" sender:self];
    }

}

- (IBAction)dismissBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    [super viewDidAppear:animated];
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
    _pageControl.currentPage = index;
}
//二维码扫描注册
- (IBAction)ScanBtn:(id)sender {
    
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"不能打开摄像头，请确认授权使用摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
    }
    
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    result=[result decryptWithDes:DES_KEY];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterPhoneNumController *registVC = [story instantiateViewControllerWithIdentifier:@"RegisterPhoneNumController"];
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSArray* list = [result componentsSeparatedByString:@"@"];
        if([list count] > 1)
        {
            self.masterId = list[0];
            [registVC setValue:@([self.masterId intValue]) forKey:@"masterStr"];
            if ([@"1" isEqualToString:list[1]]) {
                self.role=@"主人";
            }else{
                self.role=@"客人";
            }
            [registVC setValue:self.role forKey:@"suerTypeStr"];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];
    [self presentViewController:registVC animated:YES completion:nil];
    
    
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)setAntronomicalTimes:(NSArray *)antronomicalTimes
{
    _antronomicalTimes = antronomicalTimes;
//    NSString *url = [NSString stringWithFormat:@"%@UpdateAstronomicalClock.aspx",[IOManager httpAddr]];
//    NSDictionary *dic = @{@"Dawn":self.antronomicalTimes[0],@"SunRise":self.antronomicalTimes[1],@"Sunset":self.antronomicalTimes[2],@"Dusk":self.antronomicalTimes[3]};
//    HttpManager *http = [HttpManager defaultManager];
//    http.tag = 10;
//    [http sendPost:url param:dic];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    [SunCount sunrisetWithLongitude:newLocation.coordinate.longitude andLatitude:newLocation.coordinate.latitude
                        andResponse:^(SunString *str){
                            NSLog(@"%@,%@,%@,%@",str.dayspring, str.sunrise,str.sunset,str.dusk);
                            self.antronomicalTimes = @[str.dayspring,str.sunrise,str.sunset,str.dusk];
                        }];
}
@end
