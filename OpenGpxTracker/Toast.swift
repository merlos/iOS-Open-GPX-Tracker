//
//  Toast.swift
//  OpenGpxTracker
//
//  Created by Merlos on 5/28/23.
//

import Foundation
import UIKit

/// Font size of the toast

/// Supporting UILabel for Toast.
/// Setups the base label.
///  The toast adds the position color
class ToastLabel: UILabel {
    
    static let kFontSize = 16
    
    override init(frame: CGRect) {
          super.init(frame: frame)
          commonInit()
      }
      
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          commonInit()
      }
      
      convenience init(text: String) {
          self.init()
          self.text = text
      }
      
      private func commonInit() {
          textAlignment = .center
          font = UIFont.systemFont(ofSize: CGFloat(ToastLabel.kFontSize))
          alpha = 0
          numberOfLines = 0
          layer.masksToBounds = true
          layer.cornerRadius = 10
      }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

///
/// Display a toast message in a label for a few seconds and dissapears
///
///  Usage:
///
///      Toast.regular("My message") // It accepts delay in seconds and position (.top, .center .bottom)
///
///      // There are .info, .warning, .error and .success toasts.
///      Toast.info("My message", position: .top, delay: 10)
///
///  Originally extracted from https://stackoverflow.com/questions/31540375/how-to-create-a-toast-message-in-swift
///
class Toast {
    
    /// Short delay
    static let kDelayShort = 2.0
    
    /// Long delay
    static let kDelayLong = 5.0
    
    static let kDisabledDelay = -1.0
    /// Background opacity
    static let kBackgroundOpacity: Double = 0.9
    
    /// height of the toast
    static let kToastHeight = 20
    
    /// withd of the toast
    static let kToastWidth = 24
    
    ///  Offset from the closest screen edge (top or bottom).
    static let kToastOffset = 120
    
    /// Toast.regular text color
    static let kRegularTextColor: UIColor = UIColor.white
    /// Toast.regular background color
    static let kRegularBackgroundColor: UIColor = UIColor.black
    
    /// Toast.info text color
    static let kInfoTextColor: UIColor = UIColor.white
    /// Toast.info background color
    static let kInfoBackgroundColor: UIColor = UIColor(red: 0/255, green: 100/255, blue: 225/255, alpha: kBackgroundOpacity)
    
    /// Toast.success text color
    static let kSuccessTextColor: UIColor = UIColor.white
    /// Toast.success background color
    static let kSuccessBackgroundColor: UIColor = UIColor(red: 0/255, green: 150/255, blue: 0/255, alpha: kBackgroundOpacity)
  
    /// Toast.warning text color
    static let kWarningTextColor: UIColor = UIColor.black
    
    static let kWarningBackgroundColor: UIColor = UIColor(red: 255/255, green: 175/255, blue: 0/255, alpha: kBackgroundOpacity)
    
    /// Toast.error text color
    static let kErrorTextColor: UIColor = UIColor.white
    /// Toast.error background color
    static let kErrorBackgroundColor: UIColor = UIColor(red: 175/255, green: 0/255, blue: 0/255, alpha: kBackgroundOpacity)
  
    /// Position of the toast in the vertical access
    enum Position {
        case bottom
        case center
        case top
    }

    /// Singleton instance of the loading toast
    private static var manualToast: UIView?

    ///
    /// Generic implementation to show toast
    /// - Parameters:
    ///     - message: Text message to display
    ///     - textColor: Color of the text
    ///     - backgroundColor: Color of the text
    ///     - position: Position within the screen (.bottom, .center, .top)
    ///     - delay: time in seconds that the toast will be displayed
    static func showToast(_ message: String,
                          textColor: UIColor = kRegularTextColor,
                          backgroundColor: UIColor = kRegularBackgroundColor,
                          position: Position = .bottom,
                          delay: Double = kDelayLong) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        let label = ToastLabel(text: message)
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        
        var vertical: CGFloat = 0
        var size = label.intrinsicContentSize
        var width = min(size.width, window.frame.width - 60)
        if width != size.width {
            vertical = 1000
            label.textAlignment = .justified
        }
        label.textInsets = UIEdgeInsets(top: vertical, left: 15, bottom: vertical, right: 15)
       
        size = label.intrinsicContentSize
        width = min(size.width, window.frame.width - 60)
        switch position {
        case .bottom:
            label.frame = CGRect(x: CGFloat(kToastWidth),
                                 y: window.frame.height - CGFloat(kToastOffset),
                                 width: width,
                                 height: size.height + CGFloat(kToastHeight))
        case .center:
            label.frame = CGRect(x: CGFloat(kToastWidth),
                                 y: window.frame.height / 2,
                                 width: width,
                                 height: size.height + CGFloat(kToastHeight))
        case .top:
            label.frame = CGRect(x: CGFloat(kToastWidth),
                                 y: CGFloat(kToastOffset),
                                 width: width,
                                 height: size.height + CGFloat(kToastHeight))
        }
        label.center.x = window.center.x
        
        if delay == kDisabledDelay {
            manualToast = label
            window.addSubview(manualToast!)
            UIView.animate(withDuration: 0.3) {
                manualToast!.alpha = 1
            }
        } else {
            window.addSubview(label)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn,
                           animations: { label.alpha = 1 },
                           completion: { _ in
                UIView.animate(withDuration: 0.5, delay: delay,
                               options: .curveEaseOut,
                               animations: {label.alpha = 0 },
                               completion: {_ in label.removeFromSuperview()
                })
            })
        }
    }
    
    ///
    /// Displays a regular toast (black)
    /// - SeeAlso showToast
    ///
    class func regular(_ message: String, position: Position = Position.bottom, delay: Double = kDelayLong) {
        showToast(message, textColor: kRegularTextColor, backgroundColor: kRegularBackgroundColor, position: position, delay: delay)
    }
    
    ///
    ///  Information toast (blue)
    ///
    /// - SeeAlso showToast
    class func info(_ message: String,
                    position: Position = Position.bottom,
                    delay: Double = kDelayLong) {
        
        showToast(String("\u{24D8}")+"  "+message,
                  textColor: kInfoTextColor,
                  backgroundColor: kInfoBackgroundColor,
                  position: position,
                  delay: delay)
    }
    
    ///
    /// Display a warning toast (orange)
    ///
    /// - SeeAlso showToast
    class func warning(_ message: String,
                       position: Position = Position.bottom,
                       delay: Double = kDelayLong) {
        
        showToast(String("\u{26A0}")+"  "+message,
                  textColor: kWarningTextColor,
                  backgroundColor: kWarningBackgroundColor,
                  position: position,
                  delay: delay)
    }
    
    ///
    /// Display a Success toast
    ///
    /// - SeeAlso showToast
    class func success(_ message: String,
                       position: Position = Position.bottom,
                       delay: Double = kDelayLong) {
        
        showToast(String("\u{2705}")+"  "+message,
                  textColor: kSuccessTextColor,
                  backgroundColor: kSuccessBackgroundColor,
                  position: position,
                  delay: delay)
    }
    
    ///
    /// Display a error toast.
    ///
    /// - SeeAlso showToast
    ///
    class func error(_ message: String,
                     position: Position = Position.bottom,
                     delay: Double = kDelayLong) {
        showToast(String("\u{274C}")+"  "+message,
                  textColor: kErrorTextColor,
                  backgroundColor: kErrorBackgroundColor,
                  position: position,
                  delay: delay)
    }
    ///
    /// Shows a persistent loading toast with a spinner
    /// - Parameters:
    ///   - message: Text message to display alongside the spinner
    ///   - position: Position within the screen (.bottom, .center, .top)
    ///
    class func showLoading(_ message: String = "Loading...", position: Position = .center) {
        showToast(String("⌛️")+"  "+message,
                  textColor: kRegularTextColor,
                  backgroundColor: kRegularBackgroundColor,
                  position: position,
                  delay: kDisabledDelay)
    }
        
    ///
    /// Hides the persistent loading toast
    ///
    class func hideLoading() {
          guard let toast = manualToast else { return }
          UIView.animate(withDuration: 0.3, animations: {
              toast.alpha = 0
          }, completion: { _ in
              toast.removeFromSuperview()
              manualToast = nil
          })
      }
  }
