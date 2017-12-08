//
//  DialogManager.m
//  SmartHome
//
//  Created by Brustar on 16/6/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "WebManager.h"
//#import "RegisterPhoneNumController.h"

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
    CGRect rect;
    if (Is_iPhoneX) {
        rect = CGRectMake(0, 88, self.view.frame.size.width, self.view.frame.size.height-88);
    }else{
        rect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    }
    if (ON_IPAD && _isShowInSplitView) {
        rect = CGRectMake(0, 64, UI_SCREEN_WIDTH*3/4, self.view.frame.size.height-64);
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
    self.m_viewNaviBar.delegate = self;
    self.m_viewNaviBar.m_viewCtrlParent = nil;
    
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
    
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setWebView:nil];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(onWeChatPaySuccess:) name:@"WeChatPaySuccess" object:nil];
    [NC addObserver:self selector:@selector(onWeChatPayFailed:) name:@"WeChatPayFailed" object:nil];
    [NC addObserver:self selector:@selector(fetchAddressList) name:@"fetchAddressListNotification" object:nil];
}

- (void)fetchAddressList {
    [_webView reload];
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
    
    
    ////////////////////////////////////////////////   支付宝支付   //////////////////////////////////////////////////
    
    if ([reqUrl hasPrefix:@"alipays://"] || [reqUrl hasPrefix:@"alipay://"]) {
        // NOTE: 跳转支付宝App
        BOOL bSucc = [[UIApplication sharedApplication] openURL:request.URL];
        
        // NOTE: 如果跳转失败，则跳转itune下载支付宝App
        if (!bSucc) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到支付宝客户端，请用网页版支付。" preferredStyle:ON_IPAD?UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString* urlStr = @"https://itunes.apple.com/cn/app/zhi-fu-bao-qian-bao-yu-e-bao/id333206289?mt=8";
                NSURL *downloadUrl = [NSURL URLWithString:urlStr];
                [[UIApplication sharedApplication] openURL:downloadUrl];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        return NO;
    }
    
    ////////////////////////////////////////////////   关闭页面   ///////////////////////////////////////////////////
    
    if([request.URL.scheme isEqualToString:@"ecloud"])
    {
        [self cancel:nil];
        return NO;
    }
    
    ////////////////////////////////////////////////   微信支付   ///////////////////////////////////////////////////
    
    if ([request.URL.absoluteString hasPrefix:@"wxpay"]) {   //微信支付指令
        
        //if ([WXApi isWXAppInstalled]) {  //[WXApi isWXAppSupportApi]
            NSString *str = request.URL.absoluteString;
            if (str.length >0) {
                NSArray *payStringArray = [str componentsSeparatedByString:@":"];
                NSString *orderID = nil;
                if (payStringArray.count >1) {
                    orderID = payStringArray[1];
                }else {
                    [MBProgressHUD showError:@"支付参数错误"];
                    return NO;
                }
                
                if (orderID.length >0) {
                    [[WeChatPayManager sharedInstance] weixinPayWithOrderID:[orderID integerValue]];
                }else {
                    [MBProgressHUD showError:@"支付参数错误"];
                    return NO;
                }
            }
        //}else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                            message:@"未检测到微信客户端，无法支付。"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles:nil];
//            [alert show];
        //}
        
        return NO;
    }
    
    //////////////////////////////////////////////   增加地址   /////////////////////////////////////////////////////
    if ([reqUrl hasPrefix:@"addr://"]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
        DeliveryAddressSettingViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"DeliveryAddressSettingVC"];
        vc.optype = 3;// 添加
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    return YES;
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

#pragma mark - CustomNaviBarViewDelegate
- (void)onBackBtnClicked:(id)sender {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
