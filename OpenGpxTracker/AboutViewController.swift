//
//  InfoWKViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation
//import WebKit //<-- To support ios7 UIWebview will be used

class AboutViewController: UIViewController, UIWebViewDelegate {
    
    var webView: UIWebView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "About"
        
        //Add the done button
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AboutViewController.closeViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
  
        //Add the Webview
        self.webView = UIWebView(frame: self.view.frame)
        self.webView?.delegate = self
        let path = Bundle.main.path(forResource: "about", ofType: "html")
        let text = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        webView?.loadHTMLString(text!, baseURL: nil)
        self.view.addSubview(webView!)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWithRequest")
        
        if navigationType == UIWebViewNavigationType.linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    func closeViewController() {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
}
