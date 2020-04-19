//
//  DateFieldTypeView.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 15/4/20.
//

import UIKit

/// View that is meant to be attached above keyboard, supplementing default name inputs.
@available(iOS 9.0, *)
class DateFieldTypeView: UIScrollView {
    
    /// date formatter to display current time example
    private let dateFormatter = DateFormatter()
    
    /// valid date fields that are to be displayed.
    private var dateFields: [DateField] {
        get {
            var fields = [DateField]()
            // some subtitles are an attempt to clarify, in case of different Locales, causing some example of patterns to look the same.
            fields.append(DateField(type: "Year",
                                    patterns: ["YY", "YYYY"]))
            fields.append(DateField(type: "Month",
                                    patterns: ["M", "MM", "MMMMM", "MMM", "MMMM"],
                                    subtitles: ["M" : "Single",
                                                "MMMMM" : "•",
                                                "MMM" : "• • •",
                                                "MMMM" : "Full"]))
            fields.append(DateField(type: "Day",
                                    patterns: ["d", "dd", "D"],
                                    subtitles: ["d" : "Single",
                                                "dd" : "Of Month",
                                                "D" : "Of Year"]))
            fields.append(DateField(type: "Hour",
                                    patterns: ["h", "hh", "H", "HH", "K", "KK", "k", "kk"],
                                    subtitles: ["h" : "Single", "hh" : "12hr",
                                                "H" : "Single", "HH" : "24hr",
                                                "K" : "Single", "KK" : "0-11",
                                                "k" : "Single", "kk" : "1-24"]))
            fields.append(DateField(type: "Minute",
                                    patterns: ["m", "mm"],
                                    subtitles: ["m" : "Single"]))
            fields.append(DateField(type: "Second",
                                    patterns: ["s", "ss"],
                                    subtitles: ["s" : "Single"]))
            fields.append(DateField(type: "Day of the Week",
                                    patterns: ["e", "ee", "EEEEE", "EEEEEE", "E", "EEEE"],
                                    subtitles: ["e" : "Single",
                                                "EEEEE" : "•",
                                                "EEEEEE" : "• •",
                                                "E" : "• • •",
                                                "EEEE" : "Full"]))
            fields.append(DateField(type: "Time of Day",
                                    patterns: ["aaaaa", "a", "B"],
                                    subtitles: ["aaaaa" : "Single",
                                                "B" : "Text"]))
            fields.append(DateField(type: "Week",
                                    patterns: ["w", "ww", "W"],
                                    subtitles: ["w" : "Single",
                                                "ww" : "Of Year",
                                                "W" : "Of Month"]))
            fields.append(DateField(type: "Quarter",
                                    patterns: ["Q", "QQ", "QQQ", "QQQQ"]))
            fields.append(DateField(type: "Era",
                                    patterns: ["GGGGG", "G", "GGGG"]))
            fields.append(DateField(type: "Time Zone",
                                    patterns: ["X", "Z", "ZZZZZ", "z", "O", "ZZZZ", "zzzz", "VVV", "VVVV"],
                                    subtitles: ["z" : "Abbr. / GMT",
                                                "zzzz" : "Full",
                                                "X" : "GMT Offset",
                                                "O" : "GMT Short",
                                                "ZZZZ" : "GMT Full",
                                                "VVV" : "Location",
                                                "VVVV" : "Location's Time"]))
        
            return fields
        }
    }
    /// Default initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidInit()
    }
    
    /// Default initializer
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewDidInit()
    }
    
    
    /// Things to do, when view successfully inits.
    func viewDidInit() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .keyboardColor
        } else {
            self.backgroundColor = .lightKeyboard
        }
        
        // holds everything
        let scrollStack = UIStackView()
        scrollStack.axis = .horizontal
        scrollStack.distribution = .fill
        scrollStack.alignment = .leading
        scrollStack.spacing = 25
        scrollStack.translatesAutoresizingMaskIntoConstraints = false
        
        for field in dateFields {
            let vStack = genVStack(field: field)
            scrollStack.addArrangedSubview(vStack)
        }
        
        self.addSubview(scrollStack)
        self.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[sStack]-20-|", options: .alignAllLeft, metrics: nil, views: ["sStack": scrollStack]) )

    }
    
    /// Generates vertical stack that encapsulates text title, with all date patterns of same type.
    ///
    ///     |TYPE|
    ///     |genHStack(field:)|
    ///
    func genVStack(field: DateField) -> UIStackView {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.alignment = .leading
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        let textTitle = UIInsetLabel()
        textTitle.text = field.type.uppercased()
        textTitle.textColor = .gray
        textTitle.font = .boldSystemFont(ofSize: 14)
        textTitle.insets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
        
        vStack.addArrangedSubview(textTitle)
        vStack.addArrangedSubview(genHStack(field: field))
        
        return vStack
        
    }
    
    /// Generates horizontal stack that encapsulates all date patterns of same type.
    ///
    ///     |pattern|pattern|pattern|
    ///     |SUBTITLE|SUBTITLE|
    ///
    func genHStack(field: DateField) -> UIStackView {
        
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .leading
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        for pattern in field.patterns {
            let button = DatePatternButton(type: .custom)
            button.layer.cornerRadius = 10

            dateFormatter.dateFormat = pattern
            let currentDateExample = dateFormatter.string(from: Date())
            button.setTitle(currentDateExample, for: .normal)
            button.titleLabel?.text = currentDateExample
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            
            // color of button font
            if #available(iOS 13, *) {
                button.setTitleColor(.blackAndWhite, for: .normal)
            }
            else {
                button.setTitleColor(.black, for: .normal)
            }
            
            // for passing pattern to textField when needed
            button.pattern = pattern
            
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            
            // Subtitle implementation (optional)
            if let subtitle = field.subtitles?[pattern] {
                let subtitleLabel = UIInsetLabel()
                let subVStack = UIStackView()
                subVStack.axis = .vertical
                subVStack.distribution = .fill
                subVStack.alignment = .leading
                subVStack.spacing = -2.5
                subVStack.translatesAutoresizingMaskIntoConstraints = false
                
                subtitleLabel.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                subtitleLabel.text = subtitle.uppercased()
                subtitleLabel.font = .boldSystemFont(ofSize: 8)
                subtitleLabel.textAlignment = .center
                
                subVStack.addArrangedSubview(button)
                subVStack.addArrangedSubview(subtitleLabel)
                NSLayoutConstraint(item: subtitleLabel, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1, constant: 0).isActive = true
                hStack.addArrangedSubview(subVStack)
            }
            else {
                hStack.addArrangedSubview(button)
            }

        }
        
        return hStack
    }
    
    /// Called when any pattern button is tapped.
    @objc func buttonTapped(sender: DatePatternButton) {
        NotificationCenter.default.post(name: .dateFieldTapped, object: nil, userInfo: ["sender" : sender.pattern])
    }

    
}
/// Notifications name of for date pattern sending
extension Notification.Name {
    
    /// When date field type is tapped from view.
    static let dateFieldTapped = Notification.Name("dateFieldTapped")
    
}
