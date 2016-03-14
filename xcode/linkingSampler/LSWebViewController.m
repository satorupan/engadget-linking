//
//  ViewController.m
//  linkingSampler
//
//  Created by Satorupan on 2016/03/15.
//  Copyright © 2016年 paper company. All rights reserved.
//

#import "LSWebViewController.h"

@interface LSWebViewController ()<UIWebViewDelegate> {
    IBOutlet UIWebView *picaWebView;
}

@end

@implementation LSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //ページをWebViewのサイズに合わせて表示するよう設定
    picaWebView.scalesPageToFit = YES;
    picaWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    //WebViewにdelegate先のオブジェクトを指定
    picaWebView.delegate = self;
    
    
    [picaWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://linkingiot.com/"]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeModalDialog:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //ページのロードが開始されたので、ステータスバーのロード中インジケータを表示する。
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //ページのロードが終了したので、ステータスバーのロード中インジケータを非表示にする。
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //エラーが発生したので、ステータスバーのロード中インジケータを非表示にする。
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    //ロードキャンセルエラーの場合はエラー処理を行わない。
    //ページのロード途中に別のページを表示しようとした場合でも、このエラーが発生するが、
    //アプリの操作はそのまま続行できるため、エラー処理は行わない。
    if ([error code] != NSURLErrorCancelled) {
      //  エラーの内容をWebView画面に表示する。
        NSString* errString = [NSString stringWithFormat:
                               @"<html><center><font size=+7 color='red'>エラーが発生しました。:<br>%@</font></center></html>",
                               error.localizedDescription];
        [webView loadHTMLString:errString baseURL:nil];
    }
}

@end
