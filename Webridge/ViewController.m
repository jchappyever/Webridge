//
//  ViewController.m
//  Webridge
//
//  Created by linyize on 14/12/10.
//  Copyright (c) 2014年 eletech. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <WKScriptMessageHandler, WKNavigationDelegate>

@end

@implementation ViewController

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    if ([WBURI canOpenURI:url]) {
        if (decisionHandler) {
            [WBURI openURI:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.webView evaluateJavaScript:@"wbNativeToHTML('jsGetPerson', {'name':'linyize'})" completionHandler:^(id object, NSError *error) {
        NSLog(@"object:%@ error:%@", object, error);
    }];
    
    _webViewLoaded = YES;
    
    if (self.webViewFinishedBlock)
    {
        NSLog(@"self.webViewFinishedBlock");
        self.webViewFinishedBlock();
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"body: %@", message.body);
    
    [self.webridge executeFromMessage:message];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webViewLoaded = NO;

    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self name:@"webridge"];
    [conf setUserContentController:controller];
    
    self.webView = [[WBWebView alloc] initWithFrame:self.view.bounds configuration:conf];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"html.bundle"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
    
    self.webridge = [WBWebridge bridge];
    self.webridgeDelegate = [WebridgeDelegate new];
    self.webridge.delegate = self.webridgeDelegate;
    
}

@end
