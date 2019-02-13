//
//  WatchConnectivityManager.swift
//  OpenGpxTracker
//
//  Created by Vincent on 13/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import UIKit
import WatchConnectivity

@available(iOS 9.3, *)
class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    static let manager = WatchConnectivityManager()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        
    }

}
