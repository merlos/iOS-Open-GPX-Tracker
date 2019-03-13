//
//  GPXFileTableRowController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 9/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit
import SpriteKit

/// Basically a TableViewCell, but for Watch
class GPXFileTableRowController: NSObject {
    
    /// Label of cell
    @IBOutlet var fileLabel: WKInterfaceLabel!
    /*
    @IBOutlet var imageView: WKInterfaceImage!
    
    
    var lastFileName: String?
    
    func startSendIndicator(_ fileName: String?) {
        imageView.setImageNamed("Progress-")
        imageView.startAnimatingWithImages(in: NSMakeRange(1, 12), duration: 1, repeatCount: -1)
        imageView.startAnimating()
        imageView.setHidden(false)
        lastFileName = fileName
        fileLabel.setText("Sending File...")
    }
    
    func stopSendIndicator() {
        imageView.stopAnimating()
        imageView.setHidden(true)
        if let previousFileName = lastFileName {
            fileLabel.setText(previousFileName)
        }
    }
 */
}
