//
//  DateFieldTypeView.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 15/4/20.
//

import UIKit

struct DateField {
    var title: String
    var patterns: [String]
    var subtitles: [String : String]?
}

class UIInsetLabel: UILabel {
    var insets = UIEdgeInsets.zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom

        return size
    }

}


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

@available(iOS 9.0, *)
class DateFieldTypeView: UIScrollView {
        
    let dateFormatter = DateFormatter()
    
    //public var fieldType: DateFieldType
    var dateFields: [DateField] {
        get {
            var fields = [DateField]()
            fields.append(DateField(title: "Year",
                                    patterns: ["YY", "YYYY"]))
            fields.append(DateField(title: "Month",
                                    patterns: ["M", "MM", "MMMMM", "MMM", "MMMM"],
                                    subtitles: ["M" : "Single",
                                                "MMMMM" : "•",
                                                "MMM" : "• • •",
                                                "MMMM" : "Full"]))
            // some subtitles are an attempt to clarify, in case of different Locales, causing some example of patterns to look the same.
            fields.append(DateField(title: "Day",
                                    patterns: ["d", "dd", "D"],
                                    subtitles: ["d" : "Single",
                                                "dd" : "Of Month",
                                                "D" : "Of Year"]))
            fields.append(DateField(title: "Hour",
                                    patterns: ["h", "hh", "H", "HH", "K", "KK", "k", "kk"],
                                    subtitles: ["h" : "Single", "hh" : "12hr",
                                                "H" : "Single", "HH" : "24hr",
                                                "K" : "Single", "KK" : "0-11",
                                                "k" : "Single", "kk" : "1-24"]))
            fields.append(DateField(title: "Minute",
                                    patterns: ["m", "mm"],
                                    subtitles: ["m" : "Single"]))
            fields.append(DateField(title: "Second",
                                    patterns: ["s", "ss"],
                                    subtitles: ["s" : "Single"]))
            fields.append(DateField(title: "Day of the Week",
                                    patterns: ["e", "ee", "EEEEE", "EEEEEE", "E", "EEEE"],
                                    subtitles: ["e" : "Single",
                                                "EEEEE" : "•",
                                                "EEEEEE" : "• •",
                                                "E" : "• • •",
                                                "EEEE" : "Full"]))
            fields.append(DateField(title: "Period",
                                    patterns: ["aaaaa", "a", "B"],
                                    subtitles: ["aaaaa" : "Single", "B" : "Text"]))
            fields.append(DateField(title: "Week",
                                    patterns: ["w", "ww", "W"],
                                    subtitles: ["w" : "Single", "ww" : "Of Year", "W" : "Of Month"]))
            fields.append(DateField(title: "Quarter",
                                    patterns: ["Q", "QQ", "QQQ", "QQQQ"]))
            fields.append(DateField(title: "Era",
                                    patterns: ["GGGGG", "G", "GGGG"]))
            fields.append(DateField(title: "Time Zone",
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewDidInit()
    }
    
    func viewDidInit() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .keyboardColor
        } else {
            self.backgroundColor = .lightKeyboard
        }
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
        self.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[sStack]-20-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["sStack": scrollStack])
        )

    }
    
    func genVStack(field: DateField) -> UIStackView {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.alignment = .leading
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        let textTitle = UIInsetLabel()
        textTitle.text = field.title.uppercased()
        textTitle.textColor = .gray
        textTitle.font = .boldSystemFont(ofSize: 14)
        textTitle.insets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
        
        vStack.addArrangedSubview(textTitle)
        vStack.addArrangedSubview(genHStack(field: field))
        
        return vStack
        
    }
    
    func genHStack(field: DateField) -> UIStackView {
        
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .leading
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        for pattern in field.patterns {
            let button = DateFieldButton(type: .custom)
            button.layer.cornerRadius = 10

            dateFormatter.dateFormat = pattern
            let realPattern = dateFormatter.string(from: Date())
            
            button.setTitle(realPattern, for: .normal)
            button.titleLabel?.text = realPattern
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            
            if #available(iOS 13, *) {
                button.setTitleColor(.blackAndWhite, for: .normal)
            }
            else {
                button.setTitleColor(.black, for: .normal)
            }
            button.pattern = pattern
            
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            
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
    
    @objc func buttonTapped(sender: DateFieldButton) {
        NotificationCenter.default.post(name: .dateFieldTapped, object: nil, userInfo: ["sender" : sender.pattern])
    }

    
}
/// Notifications for file receival from external source.
extension Notification.Name {
    
    /// When date field type is tapped from view.
    static let dateFieldTapped = Notification.Name("dateFieldTapped")
    
}
