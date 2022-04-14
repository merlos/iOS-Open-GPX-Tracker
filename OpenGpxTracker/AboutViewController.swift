//
//  InfoWKViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//
//  Localized by nitricware on 19/08/19.
//

import UIKit
import WebKit

///
/// Controller to display the About page.
///
/// Internally it is a WKWebView that displays the resource file about.html.
///
class AboutViewController: UIViewController {
    
    /// Embedded web browser
    var webView: WKWebView?
    
    /// Initializer. Only calls super
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Initializer. Only calls super
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    ///
    /// Configures the view. Performs the following actions:
    ///
    /// 1. Sets the title to About
    /// 2. Adds "Done" button
    /// 3. Adds the webview that loads about.html from the bundle.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("ABOUT", comment: "no comment")
        
        //Add the done button
        let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
                                        style: UIBarButtonItem.Style.plain, target: self,
                                        action: #selector(AboutViewController.closeViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
  
        //Add the Webview
        self.webView = WKWebView(frame: self.view.frame, configuration: WKWebViewConfiguration())
        
        self.webView?.navigationDelegate = self
        
        let path = Bundle.main.path(forResource: "about", ofType: "html")
        let text = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        webView?.loadHTMLString(text!, baseURL: nil)
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(webView!)
    }
    
    /// Closes this view controller. Triggered by pressing the "Done" button in navigation bar.
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
}

/// Handles all navigation related stuff for the web view
extension AboutViewController: WKNavigationDelegate {
    
    /// Opens Safari when user clicks a link in the About page.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("AboutViewController: decidePolicyForNavigationAction")
        
        if navigationAction.navigationType == .linkActivated {
            UIApplication.shared.openURL(navigationAction.request.url!)
            print("AboutViewController: external link sent to Safari")
            
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
}
