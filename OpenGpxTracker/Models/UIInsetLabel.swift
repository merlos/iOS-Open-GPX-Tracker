//
//  UIInsetLabel.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 17/4/20.
//

import UIKit

/// UILabel that accepts insets padding.
class UIInsetLabel: UILabel {
    /// Insert the insets you need here. Defaults to zero.
    var insets = UIEdgeInsets.zero
    
    ///
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    ///
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom

        return size
    }

}
