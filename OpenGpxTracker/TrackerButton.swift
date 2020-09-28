import UIKit

/// Creates a button with rounded corners.
///
/// If the width and height are same, it is a circle.
///
/// By default a white background color is assigned.
///
class TrackerButton: UIButton {
    
    /// Just call `super()` and sets background color as white
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = kWhiteBackgroundColor
    }
    
    /// Override to asigns the radius of the button to height/2
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
}
