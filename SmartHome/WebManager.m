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
        self.title=@"";
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)aUrl title:(NSString *)title;
{
    self = [super init];
    if(self) {
        self.html=@"";
        self.oauthUrl = aUrl;
        self.title = title;
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
    CGRect rect = self.view.bounds;
    self.webView = [[UIWebView alloc] initWithFrame:rect];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.title isEqualToString:@""] || nil == self.title)
    {
        [self.navigationController setNavigationBarHidden:YES];
    }else{
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = left;
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

#pragma mark - UIWebView delegate
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.scheme isEqualToString:@"ecloud"])
    {
        [self cancel:nil];
        return NO;
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
//    [self dismissViewControllerAnimated:YES completion:^{
        UIViewController *ecloudVC;
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//            ecloudVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterPhoneNumController"];
//        }else{
//            ecloudVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterPhoneNumController"];
//        }
        
               ecloudVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterPhoneNumController"];
        [self.navigationController pushViewController:ecloudVC animated:YES];
//    RegisterPhoneNumController * regisVC = [RegisterPhoneNumController new];
//    regisVC.heightLayou.constant = 90;
//    }];
}

@end
