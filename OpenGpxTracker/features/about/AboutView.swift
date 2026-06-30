//
//  AboutView.swift (former AboutViewController)
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//
//  Localized by nitricware on 19/08/19.
//
//  Converted by merlos to SwiftUI on 2025-06-30
//

import SwiftUI
import WebKit

///
/// SwiftUI view to display the About page.
///
/// Internally it uses a WKWebView that displays the resource file about.html.
///
struct AboutView: View {
    var body: some View {
        WebViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

/// UIViewRepresentable wrapper for WKWebView
struct WebViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = context.coordinator
        
        // Load the about.html file
        if let path = Bundle.main.path(forResource: "about", ofType: "html"),
           let html = try? String(contentsOfFile: path, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
}

/// Coordinator to handle WKNavigationDelegate
class WebViewCoordinator: NSObject, WKNavigationDelegate {
    
    /// Opens Safari when user clicks a link in the About page.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("AboutView: decidePolicyForNavigationAction")
        
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
            print("AboutView: external link sent to Safari")
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - UIViewController wrapper for backward compatibility
///
/// UIViewController wrapper to present the SwiftUI AboutView.
/// This maintains compatibility with existing code that expects a UIViewController.
///
class AboutViewController: UIViewController {
    
    /// Initializer. Only calls super
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Initializer. Only calls super
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    ///
    /// Configures the view with SwiftUI content.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("ABOUT", comment: "no comment")
        
        // Add the done button
        let doneButton = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(closeViewController))
        self.navigationItem.rightBarButtonItem = doneButton
        
        // Create and host the SwiftUI view
        let aboutView = AboutView()
        let hostingController = UIHostingController(rootView: aboutView)
        
        // Add as child view controller
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    /// Closes this view controller. Triggered by pressing the "Done" button in navigation bar.
    @objc func closeViewController() {
        self.dismiss(animated: true)
    }
}
