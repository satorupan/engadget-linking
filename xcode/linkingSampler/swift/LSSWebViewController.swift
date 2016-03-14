//
//  LSSWebViewController.swift
//  linkingSampler
//
//  Created by Satorupan on 2016/03/15.
//  Copyright © 2016年 paper company. All rights reserved.
//

import UIKit

class LSSWebViewController: UIViewController,UIWebViewDelegate{

    //MARK: - Properties
    @IBOutlet private var webview: UIWebView!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //webview = UIWebView(frame : self.view.bounds)
        //webview.delegate = self;
        //self.view.addSubview(webview)
        
        // NSURLのinitializer(public convenience init?(string URLString: String))は返り値がoptional型なので扱いに注意
        let url = NSURL(string : "https://linkingiot.com/")
        let urlRequest = NSURLRequest(URL: url!)
        self.webview.loadRequest(urlRequest)
    }
    
    //MARK: - UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    @IBAction func TouchTestButton(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: {_ in})
        
    }

}
