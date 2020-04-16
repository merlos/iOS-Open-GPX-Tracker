//
//  UIColor+DarkMode.swift
//  OpenGpxTracker
//
//  Created by Vincent on 29/11/19.
//

import UIKit

@available(iOS 13.0, *)
/// To better support dark mode color switches.
extension UIColor {
    
    /// Main UI color
    static let mainUIColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
            case .unspecified, .light:  return UIColor(red: 0, green: 0.61, blue: 0.86, alpha: 1)
            case .dark:                 return .white
            @unknown default:           return UIColor(red: 0, green: 0.61, blue: 0.86, alpha: 1)
                }
    }
    
    /// Returns a colour opposite of trait collection (i.e. light gets black, dark gets white.)
    static let blackAndWhite = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
            case .unspecified, .light:  return .black
            case .dark:                 return .white
            @unknown default:           return .systemGray
                }
    }

    static let keyboardColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
            case .unspecified, .light:  return .lightKeyboard
            case .dark:                 return .darkKeyboard
            @unknown default:           return .lightKeyboard
                }
    }
    
    static let highlightKeyboardColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
            case .unspecified, .light:  return .highlightLightKeyboard
            case .dark:                 return .highlightDarkKeyboard
            @unknown default:           return .highlightLightKeyboard
                }
    }
    
}

extension UIColor {
    static let lightKeyboard = UIColor(red: 209/255, green: 213/255, blue: 219/255, alpha: 1.00)
    static let darkKeyboard = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1.00)
    
    static let highlightLightKeyboard = UIColor(red: 229/255, green: 233/255, blue: 239/255, alpha: 1.00)
    static let highlightDarkKeyboard = UIColor(red: 56/255, green: 56/255, blue: 56/255, alpha: 1.00)
}
