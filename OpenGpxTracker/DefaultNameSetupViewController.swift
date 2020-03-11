//
//  DefaultNameSetupViewController.swift
//  OpenGpxTracker
//
//  Created by Vincent on 3/3/20.
//

import UIKit

class DefaultNameSetupViewController: UITableViewController, UITextFieldDelegate {
    
    var cellTextField = UITextField()
    var cellSampleLabel = UILabel()
    
    var processedDateFormat = String()
    let defaultDateFormat = DefaultDateFormat()
    
    var useUTC = false
    var useEN = false
    
    /// Global Preferences
    var preferences : Preferences = Preferences.shared

    let presets =  [("Defaults", "dd-MMM-yyyy-HHmm", "{dd}-{MMM}-{yyyy}-{HH}{mm}"),
                    ("ISO8601 (UTC)", "yyyy-MM-dd'T'HH:mm:ss'Z'", "{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}Z"),
                    ("ISO8601 (UTC offset)", "yyyy-MM-dd'T'HH:mm:ssZ", "{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}{Z}"),
                    ("Day, Date at time (12 hr)", "EEEE, MMM d, yyyy 'at' h:mm a", "{EEEE}, {MMM} {d}, {yyyy} at {h}:{mm} {a}"),
                    ("Day, Date at time (24 hr)", "EEEE, MMM d, yyyy 'at' HH:mm", "{EEEE}, {MMM} {d}, {yyyy} at {HH}:{mm}")]
    
    /// Sections of table view
    private enum kSections: Int, CaseIterable {
        case input, settings, presets
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        useUTC = preferences.dateFormatUseUTC
        useEN = preferences.dateFormatUseEN
    }
    
    // MARK:- Text Field Related
    
    @objc func buttonTapped(_ sender: UIBarButtonItem, for event: UIEvent) {
        if cellTextField.text != nil {
            switch sender.tag {
            case 0: cellTextField.insertText("{dd}")
            case 1: cellTextField.insertText("{MM}")
            case 2: cellTextField.insertText("{yyyy}")
            case 3: cellTextField.insertText("{HH}")
            case 4: cellTextField.insertText("{mm}")
            case 5: cellTextField.insertText("{ss}")
            case 6:
                cellTextField.insertText("{}")
                
                guard let currRange = cellTextField.selectedTextRange,
                      let wantedRange = cellTextField.position(from: currRange.start, offset: -1) else { return }
                cellTextField.selectedTextRange = cellTextField.textRange(from: wantedRange, to: wantedRange)
            default: return
            }
            textFieldTyping()
        }
    }

    @objc func textFieldTyping() {
        processedDateFormat = defaultDateFormat.getDateFormat(unprocessed: self.cellTextField.text!)
        //dateFormatter.dateFormat = processedDateFormat
        cellSampleLabel.text = defaultDateFormat.getDate(processedFormat: processedDateFormat, useUTC: useUTC, useENLocale: useEN)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //remove checkmark from selected date format preset, as textfield edited == not preset anymore
        let selectedIndexPath = IndexPath(row: preferences.dateFormatPreset, section: kSections.presets.rawValue)
        tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        useUTC = false
        lockUTCCell(useUTC)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if cellTextField.text != preferences.dateFormatInput {
            saveDateFormat(processedDateFormat, input: cellTextField.text)

        }
        else {
            let selectedIndexPath = IndexPath(row: preferences.dateFormatPreset, section: kSections.presets.rawValue)
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .checkmark
            
            if preferences.dateFormatPreset == 1 {
                useUTC = true
                lockUTCCell(useUTC)
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func saveDateFormat(_ dateFormat: String, input: String?, index: Int = -1) {
        guard let input = input else { return }
        if dateFormat == "invalid" || input.isEmpty || dateFormat.isEmpty { return } // ensures no invalid date format (revert)
        preferences.dateFormat = dateFormat
        preferences.dateFormatInput = input
        preferences.dateFormatPreset = index
        preferences.dateFormatUseUTC = useUTC
    }
    
    func lockUTCCell(_ state: Bool) {
        let indexPath = IndexPath(row: 0, section: kSections.settings.rawValue)
        useUTC = state
        
        tableView.cellForRow(at: indexPath)?.accessoryType = state ? .checkmark : .none
        tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = !state
        tableView.cellForRow(at: indexPath)?.textLabel?.isEnabled = !state
        textFieldTyping()
    }
    
    // MARK:- Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return kSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kSections.input.rawValue: return NSLocalizedString("DEFAULT_NAME_DATE_FORMAT", comment: "no comment")
        case kSections.settings.rawValue: return NSLocalizedString("DEFAULT_NAME_SETTINGS", comment: "no comment")
        case kSections.presets.rawValue: return NSLocalizedString("DEFAULT_NAME_PRESET", comment: "no comment")
        default: fatalError("Section out of range")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == kSections.input.rawValue {
            return NSLocalizedString("DEFAULT_NAME_INPUT_FOOTER", comment: "no comment")
        }
        else { return nil }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kSections.input.rawValue: return 2
        case kSections.settings.rawValue:
            if Locale.current.languageCode == "en" {
                return 1 // force locale to EN should only be shown if Locale is not EN.
            }
            else { return 2 }
        case kSections.presets.rawValue: return presets.count
        default: fatalError("Row out of range")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: .default, reuseIdentifier: "inputCell")
        
        if indexPath.section == kSections.input.rawValue {
            if indexPath.row == 0 {
                
                cellSampleLabel = UILabel(frame: CGRect(x: 87, y: 0, width: view.frame.width - 99, height: cell.frame.height))
                cellSampleLabel.font = .boldSystemFont(ofSize: 17)
                cell.addSubview(cellSampleLabel)
                cellSampleLabel.text = ""
                cellSampleLabel.adjustsFontSizeToFitWidth = true
                cell.textLabel!.text = NSLocalizedString("DEFAULT_NAME_SAMPLE_OUTPUT_TITLE", comment: "no comment")
                cell.textLabel?.font = .systemFont(ofSize: 17)
                
            }
            else if indexPath.row == 1 {
                cellTextField = UITextField(frame: CGRect(x: 22, y: 0, width: view.frame.width - 48, height: cell.frame.height))
                //let textView = UITextView(frame: CGRect(x: 25, y: 5, width: view.frame.width - 50, height: cell.frame.height))
                cellTextField.text = preferences.dateFormatInput
                textFieldTyping()
                cellTextField.clearButtonMode = .whileEditing
                cellTextField.delegate = self
                cellTextField.returnKeyType = .done
                let bar = UIToolbar()
                let bracket = UIBarButtonItem(title: "{ ... }", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                bracket.tag = 6
                let day = UIBarButtonItem(title: "Day", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                day.tag = 0
                let month = UIBarButtonItem(title: "Month", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                month.tag = 1
                let year = UIBarButtonItem(title: "Year", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                year.tag = 2
                let hour = UIBarButtonItem(title: "Hr", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                hour.tag = 3
                let min = UIBarButtonItem(title: "Min", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                min.tag = 4
                let sec = UIBarButtonItem(title: "Sec", style: .plain, target: self, action: #selector(buttonTapped(_:for:)))
                sec.tag = 5

                bar.items = [bracket, day, month, year, hour, min, sec]
                bar.sizeToFit()
                cellTextField.addTarget(self, action: #selector(textFieldTyping), for: UIControl.Event.editingChanged)
                cellTextField.inputAccessoryView = bar

                cell.contentView.addSubview(cellTextField)
                if indexPath.section == kSections.input.rawValue {
                    
                }
            }
            cell.selectionStyle = .none
            cellTextField.autocorrectionType = .no
        }
            
        else if indexPath.section == kSections.settings.rawValue {
            if indexPath.row == 0 {
                cell.textLabel!.text = NSLocalizedString("DEFAULT_NAME_USE_UTC", comment: "no comment")//"Use UTC?"
                cell.accessoryType = preferences.dateFormatUseUTC ? .checkmark : .none
                
                if preferences.dateFormatPreset == 1 {
                    cell.isUserInteractionEnabled = !useUTC
                    cell.textLabel?.isEnabled = !useUTC
                }
            }
            else if indexPath.row == 1 {
                cell.textLabel!.text = NSLocalizedString("DEFAULT_NAME_ENGLISH_LOCALE", comment: "no comment")//"Force English Locale?"
                cell.accessoryType = preferences.dateFormatUseEN ? .checkmark : .none
            }
        }
        
        else if indexPath.section == kSections.presets.rawValue {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "presetCell")
            cell.textLabel?.text = presets[indexPath.row].0
            cell.detailTextLabel?.text = presets[indexPath.row].1
            
            if preferences.dateFormatPreset != -1 { // if not custom
                cell.accessoryType = preferences.dateFormatPreset == indexPath.row ? .checkmark : .none
            }
        }

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == kSections.settings.rawValue {
            if indexPath.row == 0 {
                //remove checkmark from selected utc setting
                let newUseUTC = !preferences.dateFormatUseUTC
                preferences.dateFormatUseUTC = newUseUTC
                useUTC = newUseUTC
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseUTC ? .checkmark : .none
            }
            else if indexPath.row == 1 {
                //remove checkmark from selected en locale setting
                let newUseEN = !preferences.dateFormatUseEN
                preferences.dateFormatUseEN = newUseEN
                useEN = newUseEN
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseEN ? .checkmark : .none
            }
            textFieldTyping()
        }
        if indexPath.section == kSections.presets.rawValue {
            //cellSampleLabel.text = "{\(presets[indexPath.row].1)}"
            cellTextField.text = presets[indexPath.row].2
            
            //update cell UI
            //remove checkmark from selected date format preset
            let selectedIndexPath = IndexPath(row: preferences.dateFormatPreset, section: indexPath.section)
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
            
            //add checkmark to new selected date format preset
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.dateFormatPreset = indexPath.row
            preferences.dateFormatInput = presets[indexPath.row].2
            textFieldTyping()
            preferences.dateFormat = processedDateFormat
            if preferences.dateFormatPreset == 1 {
                lockUTCCell(true)
            }
            else {
                lockUTCCell(false)
            }
            preferences.dateFormatUseUTC = useUTC
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
