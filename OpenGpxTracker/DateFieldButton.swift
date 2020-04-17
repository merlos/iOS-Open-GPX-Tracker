//
//  DateFieldButton.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 17/4/20.
//

import UIKit

class DateFieldButton: UIButton {
    
    var pattern = String()
    
    override var isSelected: Bool {
        didSet {
            if #available(iOS 13.0, *) {
                backgroundColor = isSelected ?  .highlightKeyboardColor : .keyboardColor
            } else {
                backgroundColor = isSelected ?  .highlightLightKeyboard : .lightKeyboard
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if #available(iOS 13.0, *) {
                backgroundColor = isHighlighted ?  .highlightKeyboardColor : .keyboardColor
            } else {
                backgroundColor = isHighlighted ?  .highlightLightKeyboard : .darkKeyboard
            }
        }
    }
    
}
