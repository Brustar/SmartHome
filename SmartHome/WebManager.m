//
//  DialogManager.m
//  SmartHome
//
//  Created by Brustar on 16/6/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "WebManager.h"
#import "ECloudTabBarController.h"
#import "RegisterPhoneNumController.h"


@implementation WebManager

+ (void)show:(NSString *)aUrl
{
    WebManager *web = [[WebManager alloc] initWithUrl:aUrl title:@"逸云科技"];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:web];
    web.navigationController.navigationBarHidden = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    [rootViewController dismissViewControllerAnimated:NO completion:nil];
    [rootViewController presentViewController:controller animated:YES completion:nil];
}

- (id)initWithHtml:(NSString *)html
{
    self = [super init];
    if(self) {
        self.html = html;
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)aUrl title:(NSString *)title;
{
    self = [super init];
    if(self) {
        self.html=@"";
        self.oauthUrl = aUrl;
        self.naviTitle = title;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    CGRect rect = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44);
    if (ON_IPAD && _isShowInSplitView) {
        rect = CGRectMake(0, 44, UI_SCREEN_WIDTH*3/4, self.view.frame.size.height-44);
    }
    self.webView = [[UIWebView alloc] initWithFrame:rect];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:self.webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotifications];
    [self setNaviBarTitle:self.naviTitle];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && _isShowInSplitView) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
    }
    
    [MBProgressHUD showMessage:@"加载中..."];
    
    if([self.html isEqualToString:@""]){
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.oauthUrl]
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:60.0];
        [self.webView loadRequest:request];
    }else{
        [self.webView loadHTMLString:self.html baseURL:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setWebView:nil];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(onWeChatPaySuccess:) name:@"WeChatPaySuccess" object:nil];
    [NC addObserver:self selector:@selector(onWeChatPayFailed:) name:@"WeChatPayFailed" object:nil];
    
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)onWeChatPaySuccess:(NSNotification *)noti {
    int userID = [[UD objectForKey:@"UserID"] intValue];
    self.oauthUrl = [[IOManager httpAddr] stringByAppendingString:[NSString stringWithFormat:@"/ui/PaySuccess.aspx?user_id=%d", userID]];
    self.naviTitle = @"支付成功";
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.oauthUrl]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [self.webView loadRequest:request];
}

- (void)onWeChatPayFailed:(NSNotification *)noti {
    [MBProgressHUD showError:@"支付失败"];
}

#pragma mark - UIWebView delegate
/*- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.scheme isEqualToString:@"ecloud"])
    {
        [self cancel:nil];
        return NO;
    }
    return YES;
}*/

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // NOTE: ------  对alipays:相关的scheme处理 -------
    // NOTE: 若遇到支付宝相关scheme，则跳转到本地支付宝App
    NSString* reqUrl = request.URL.absoluteString;
    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
        // NOTE: 跳转支付宝App
        BOOL bSucc = [[UIApplication sharedApplication] openURL:request.URL];
        
        // NOTE: 如果跳转失败，则跳转itune下载支付宝App
        if (!bSucc) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                           message:@"未检测到支付宝客户端，请用网页版支付。"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        return NO;
    }
    
    
    if([request.URL.scheme isEqualToString:@"ecloud"])
    {
        [self cancel:nil];
        return NO;
    }
    
    if ([request.URL.absoluteString hasPrefix:@"wxpay"]) {   //微信支付指令
        
        NSString *str = request.URL.absoluteString;
        if (str.length >0) {
            NSArray *payStringArray = [str componentsSeparatedByString:@":"];
            NSString *orderID = nil;
            if (payStringArray.count >1) {
                orderID = payStringArray[1];
            }
            
            if (orderID.length >0) {
                [[WeChatPayManager sharedInstance] weixinPayWithOrderID:[orderID integerValue]];
            }
        }
        
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // NOTE: 跳转itune下载支付宝App
    //NSString* urlStr = @"https://itunes.apple.com/cn/app/zhi-fu-bao-qian-bao-yu-e-bao/id333206289?mt=8";
    //NSURL *downloadUrl = [NSURL URLWithString:urlStr];
    //[[UIApplication sharedApplication] openURL:downloadUrl];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUD];
}

//oAuth2
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUD];
}

#pragma mark Action
- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [self removeNotifications];
}

@end
