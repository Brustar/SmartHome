//
//  DialogManager.m
//  SmartHome
//
//  Created by Brustar on 16/6/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "WebManager.h"

@implementation WebManager

+ (void) show:(NSString *)aUrl
{
    WebManager *web = [[WebManager alloc] initWithUrl:aUrl title:@"逸云科技"];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:web];
    web.navigationController.navigationBarHidden = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    [rootViewController dismissModalViewControllerAnimated:NO];
    [rootViewController presentModalViewController:controller animated:YES];
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
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = left;
    }
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.waitingIndicator = aiv;
    
    self.waitingIndicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.waitingIndicator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:self.waitingIndicator];
    [self.waitingIndicator setHidesWhenStopped:YES];
    [self.waitingIndicator startAnimating];
    
    [self.view bringSubviewToFront:self.waitingIndicator];
    
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
    [self setWaitingIndicator:nil];
}

#pragma mark - UIWebView delegate
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.waitingIndicator stopAnimating];
}

//oAuth2
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.waitingIndicator stopAnimating];
}

#pragma mark Action
- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
