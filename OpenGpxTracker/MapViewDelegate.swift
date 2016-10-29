import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate, UIAlertViewDelegate {

    var waypointBeingEdited: GPXWaypoint = GPXWaypoint()
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        let annotationView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
        annotationView.canShowCallout = true
        annotationView.isDraggable = true
        //let detailButton: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        
        let deleteButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        deleteButton.setImage(UIImage(named: "delete"), for: UIControlState())
        deleteButton.setImage(UIImage(named: "deleteHigh"), for: .highlighted)
        deleteButton.tag = kDeleteWaypointAccesoryButtonTag
        annotationView.rightCalloutAccessoryView = deleteButton
        
        let editButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        editButton.setImage(UIImage(named: "edit"), for: UIControlState())
        editButton.setImage(UIImage(named: "editHigh"), for: .highlighted)
        editButton.tag = kEditWaypointAccesoryButtonTag
        annotationView.leftCalloutAccessoryView = editButton
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKTileOverlay.self) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.blue.withAlphaComponent(0.5)
            pr.lineWidth = 3
            return pr
        }
        return MKOverlayRenderer()
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccesoryControlTapped ")
        guard let waypoint = view.annotation as? GPXWaypoint else {
            return
        }
        
        guard let button = control as? UIButton else {
            return
        }
        
        guard let map = mapView as? GPXMapView else {
            return
        }
        
        switch button.tag {
        case kDeleteWaypointAccesoryButtonTag:
            print("[calloutAccesoryControlTapped: DELETE button] deleting waypoint with name \(waypoint.name)")
            map.removeWaypoint(waypoint)
        case kEditWaypointAccesoryButtonTag:
            print("[calloutAccesoryControlTapped: EDIT] editing waypoint with name \(waypoint.name)")
            let alert = UIAlertView(title: "Edit Waypoint",
                message: "Hint: To change the waypoint location drag and drop the pin",
                delegate: self, cancelButtonTitle: "Cancel")
            alert.addButton(withTitle: "Save")
            alert.tag = kEditWaypointAlertViewTag
            alert.alertViewStyle = .plainTextInput
            alert.textField(at: 0)?.text = waypoint.title
            alert.show()
            self.waypointBeingEdited = waypoint
            alert.textField(at: 0)?.selectAll(self) //display text selected <-- TODO Not working WTF!
            
        default:
            print("[calloutAccesoryControlTapped ERROR] unknown control")
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
            
            if newState == MKAnnotationViewDragState.ending {
                if let point = view.annotation as? GPXWaypoint {
                    print("Annotation name: \(point.title) lat:\(point.latitude) lon \(point.longitude)")
                }
            }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        var i = 0
        for object in views {
            i += 1
            let aV = object as MKAnnotationView
            if aV.annotation!.isKind(of: MKUserLocation.self) { continue }
            
            let point: MKMapPoint = MKMapPointForCoordinate(aV.annotation!.coordinate)
            if !MKMapRectContainsPoint(mapView.visibleMapRect, point) { continue }
            
            let endFrame: CGRect = aV.frame
            aV.frame = CGRect(x: aV.frame.origin.x, y: aV.frame.origin.y - mapView.superview!.frame.size.height,
                width: aV.frame.size.width, height:aV.frame.size.height)
            let interval: TimeInterval = 0.04 * 1.1
            UIView.animate(withDuration: 0.5, delay: interval, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                aV.frame = endFrame
                }, completion: { (finished) -> Void in
                    if finished {
                        UIView.animate(withDuration: 0.05, animations: { () -> Void in
                            //aV.transform = CGAffineTransformMakeScale(1.0, 0.8)
                            aV.transform = CGAffineTransform(a: 1.0, b: 0, c: 0, d: 0.8, tx: 0, ty: aV.frame.size.height*0.1)
                            
                            }, completion: { (finished: Bool) -> Void in
                                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                                    aV.transform = CGAffineTransform.identity
                                })
                        })
                    }
            })
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        switch alertView.tag {
        case kEditWaypointAlertViewTag:
            print("Edit waypoint alert view")
            self.waypointBeingEdited.title = alertView.textField(at: 0)?.text
            
        default:
            print("[ERROR] it seems that the AlertView is not handled properly." )
            
        }
    }
}
