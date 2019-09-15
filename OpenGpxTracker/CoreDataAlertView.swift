//
//  CoreDataAlertView.swift
//  OpenGpxTracker
//
//  Created by Vincent on 25/6/19.
//

import UIKit

/// To display Core Data alert action sheet anywhere when needed.
///
/// It should display anywhere possible, in case if a gpx file loads too long when file recovery with previous session's file is too big.
struct CoreDataAlertView {
    
    /// shows the action sheet that prompts user on what to do with recovered data.
    func showActionSheet(_ alertController: UIAlertController) {
        guard let appDelegate = UIApplication.shared.delegate else { return }
        guard let rootVC = appDelegate.window!?.rootViewController else { return }
        
        if let popoverController = alertController.popoverPresentationController {
            guard let view = rootVC.view else { return }
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        rootVC.present(alertController, animated: true, completion: nil)
    }
    
}
