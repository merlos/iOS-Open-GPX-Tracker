//
//  GPXFileTableInterfaceController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 7/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit
import Foundation


class GPXFileTableInterfaceController: WKInterfaceController {
    
    @IBOutlet var fileTable: WKInterfaceTable!
    
    /// List of strings with the filenames.
    var fileList: NSMutableArray = [kNoFiles]
    
    /// Is there any GPX file in the directory?
    var gpxFilesFound = false;
    
    /// Temporary variable to manage
    var selectedRowIndex = -1
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setTitle("Your GPX Files")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
