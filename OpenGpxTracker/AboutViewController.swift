//
//  InfoWKViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation
//import WebKit //<-- To support ios7 UIWebview will be used

class AboutViewController : UIViewController, UIWebViewDelegate {
    
    var webView : UIWebView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "About"
        
        //Add the done button
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: "closeViewController")
        self.navigationItem.rightBarButtonItems = [shareItem]
  
        //Add the Webview
        self.webView = UIWebView(frame: self.view.frame)
        self.webView?.delegate = self
        var path = NSBundle.mainBundle().pathForResource("about", ofType: "html")
        let text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil);
        
        webView?.loadHTMLString(text, baseURL: nil)
        self.view.addSubview(webView!)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println("shouldStartLoadWithRequest")
        
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        return true
    }
    
    func closeViewController() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    
    
}
