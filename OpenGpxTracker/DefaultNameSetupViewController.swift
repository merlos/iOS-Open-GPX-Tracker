//
//  DefaultNameSetupViewController.swift
//  OpenGpxTracker
//
//  Created by Vincent on 3/3/20.
//

import UIKit

class DefaultNameSetupViewController: UITableViewController, UITextFieldDelegate {
    
    var cellTextField = UITextField()
    var label = UILabel()

    
    /// Sections of table view
    private enum kSections: Int, CaseIterable {
        case input, presets
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return kSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kSections.input.rawValue: return "Input"
        case kSections.presets.rawValue: return "Presets"
        default: fatalError("Section out of range")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kSections.input.rawValue: return 2
        case kSections.presets.rawValue: return 0 //placeholder
        default: fatalError("Section out of range")
        }
    }
    
    @objc func buttonTapped(_ sender: UIBarButtonItem, for event: UIEvent) {
        if cellTextField.text != nil {
            switch sender.tag {
            case 0: cellTextField.insertText("{dd}")
            case 1: cellTextField.insertText("{MM}")
            case 2: cellTextField.insertText("{yyyy}")
            case 3: cellTextField.insertText("{HH}")
            case 4: cellTextField.insertText("{mm}")
            case 5: cellTextField.insertText("{ss}")
            default: return
            }
            textFieldTyping()
        }
        
    }

    @objc func textFieldTyping() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DefaultDateFormat.getDateFormat(unprocessed: self.cellTextField.text!)
        label.text = dateFormatter.string(from: Date())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "inputCell")
        if indexPath.row == 0 {
            
            label = UILabel(frame: CGRect(x: 82, y: 0, width: view.frame.width - 97, height: cell.frame.height))
            cell.addSubview(label)
            label.text = ""
            cell.textLabel!.text = "Sample: "
            if #available(iOS 8.2, *) {
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .thin)
            }
        }
        if indexPath.row == 1 {
            cellTextField = UITextField(frame: CGRect(x: 25, y: 0, width: view.frame.width - 50, height: cell.frame.height))
            //let textView = UITextView(frame: CGRect(x: 25, y: 5, width: view.frame.width - 50, height: cell.frame.height))
            cellTextField.text = ""
            //cellTextField.placeholder = "Default Name"
            cellTextField.delegate = self
            cellTextField.returnKeyType = .done
            let bar = UIToolbar()
            let day = UIBarButtonItem(title: "Day", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
            day.tag = 0
            let month = UIBarButtonItem(title: "Month", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
            month.tag = 1
            let year = UIBarButtonItem(title: "Year", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
            year.tag = 2
            let hour = UIBarButtonItem(title: "Hour", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
            hour.tag = 3
            let min = UIBarButtonItem(title: "Minute", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
            min.tag = 4
            let sec = UIBarButtonItem(title: "Second", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
            sec.tag = 5

            bar.items = [day, month, year, hour, min, sec]
            bar.sizeToFit()
            cellTextField.addTarget(self, action: #selector(textFieldTyping), for: UIControl.Event.editingChanged)
            cellTextField.inputAccessoryView = bar

            cell.contentView.addSubview(cellTextField)
            if indexPath.section == kSections.input.rawValue {
                
            }
        }
        return cell
    }
    

}
