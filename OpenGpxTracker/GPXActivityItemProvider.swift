//
//  GPXActivityItemProvider.swift
//  OpenGpxTracker
//
//  Created by Ian Grossberg on 9/19/18.
//  Copyright © 2018 TransitBox. All rights reserved.
//

import UIKit

class GPXActivityItemProvider: UIActivityItemProvider {
    let gpxFileData: Data
    
    init(gpxFileData: Data) {
        self.gpxFileData = gpxFileData
        super.init(placeholderItem: gpxFileData)
    }
    
    override var item: Any {
        return self.gpxFileData
    }
    
    override func activityViewController(
        _ activityViewController: UIActivityViewController,
        dataTypeIdentifierForActivityType activityType: UIActivityType?
        ) -> String {
        return "com.topografix.gpx"
    }
}
