//
//  GPXActivityItemProvider.swift
//  OpenGpxTracker
//
//  Created by Ian Grossberg on 9/19/18.
//  Copyright © 2018 TransitBox. All rights reserved.
//

import UIKit

class GPXActivityItemProvider: UIActivityItemProvider {
    let filename: String
    let gpxFileData: Data
    
    init(filename: String, gpxFileData: Data) {
        self.filename = filename
        self.gpxFileData = gpxFileData
        super.init(placeholderItem: gpxFileData)
    }

    override var item: Any {
        return self.gpxFileData
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return self.filename
    }
    
    override func activityViewController(
        _ activityViewController: UIActivityViewController,
        dataTypeIdentifierForActivityType activityType: UIActivityType?
        ) -> String {
        return "com.topografix.gpx"
    }
}
