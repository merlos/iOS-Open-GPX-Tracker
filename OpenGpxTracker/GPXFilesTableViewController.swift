//
//  GPXFilesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 14/09/14.
//
//  Localized by nitricware on 19/08/19.
//

import Foundation
import UIKit
import CoreGPX
import MessageUI
import WatchConnectivity
import CoreServices

/// Text displayed when there are no GPX files in the folder.
let kNoFiles = NSLocalizedString("NO_FILES", comment: "no comment")

///
/// TableViewController that displays the list of files that have been saved in previous sessions.
///
/// This view controller allows users to manage their GPX Files.
///
/// Currently the following actions with a file are supported
///
/// 1. Send it by email
/// 2. Load in the map
/// 3. Delete the file
///
/// It also displays a button "Done" in the navigation bar to return to the map.
///
class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate, UIDocumentPickerDelegate {
    
    /// List of strings with the filenames.
    var fileList: NSMutableArray = [kNoFiles]
    
    /// Is there any GPX file in the directory?
    var gpxFilesFound = false
    
    /// Temporary variable to manage.
    var selectedRowIndex = -1
    
    ///
    weak var delegate: GPXFilesTableViewControllerDelegate?
    
    var folderLabel: UILabel = UILabel()
    ///
    /// Setups the view controller.
    ///
    /// 1. Sets the title & folder
    /// 2. Adds the "Done" and choose folder buttons
    /// 3. Loads existing GPX File list.
    ///
    override func viewDidLoad() {
        /*
         super.viewDidLoad()
         let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
         self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
         self.view.frame.height - navBarFrame.height)
         
         self.title = NSLocalizedString("YOUR_FILES", comment: "no comment")
         
         // add notification observer for reloading table when file is added.
         addNotificationObservers()
         
         // Button to return to the map
         let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
         style: UIBarButtonItem.Style.plain,
         target: self,
         action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
         
         self.navigationItem.rightBarButtonItems = [shareItem]
         */
        super.viewDidLoad()
        if let appDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("App Documents Directory: \(appDirectory.path)")
            
        }        // Set up navigation bar dimensions and table view frame
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height: self.view.frame.height - navBarFrame.height)
        
        // Add a custom title and subtitle view to the navigation bar
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("YOUR_FILES", comment: "no comment")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle label
        folderLabel.text = GPXFileManager.GPXFilesFolderURL.lastPathComponent
        folderLabel.font = UIFont.systemFont(ofSize: 13)
        folderLabel.textColor = .gray
        folderLabel.textAlignment = .center
        folderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add labels to the titleView
        titleView.addSubview(titleLabel)
        titleView.addSubview(folderLabel)
        
        // Add constraints for title and subtitle labels
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            
            folderLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            folderLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            folderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            folderLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
        
        // Assign the custom view to the navigation item's titleView
        self.navigationItem.titleView = titleView
        
        // Add the "Done" button to the navigation bar
        // Button to return to the map
        let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
                                        style: UIBarButtonItem.Style.plain,
                                        target: self,
                                        action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        // Add the button to select the current folder
        var folderButton: UIBarButtonItem = UIBarButtonItem()
        if #available(iOS 13.0, *) {
            folderButton = UIBarButtonItem(image: UIImage(systemName: "folder"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(folderButtonTapped))
            
        } else {
            folderButton = UIBarButtonItem(title: NSLocalizedString("FOLDER", comment: "no comment"),
                                           style: UIBarButtonItem.Style.plain,
                                           target: self,
                                           action: #selector(folderButtonTapped))
            
        }
        self.navigationItem.leftBarButtonItems = [folderButton]
        
        _ = GPXFileManager.GPXFilesFolderURL.startAccessingSecurityScopedResource()
        // Initial load of the data
        let list: [GPXFileInfo] = GPXFileManager.fileList
        gpxFilesFound =  list.count != 0
        self.fileList.removeAllObjects()
        if gpxFilesFound {
            self.fileList.addObjects(from: list)
        } else {
            self.fileList.addObjects(from: [kNoFiles])
        }
    }
    
    /// Removes notfication observers
    deinit {
        GPXFileManager.GPXFilesFolderURL.stopAccessingSecurityScopedResource()
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Closes this view controller.
    @objc func closeGPXFilesTableViewController() {
        print("GPXFIlesTableViewController: closeGPXFIlesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    /// Handle the folder button action
    @objc func folderButtonTapped() {
        print("GPXFIlesTableViewController: Folder button tapped")
        let documentVC = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentVC.allowsMultipleSelection = false
        documentVC.delegate = self
        self.present(documentVC, animated: true)
    }
    
    /// Reloads data whenver the table appears.
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    /// Disposes resources in case of a mermory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view data source
    
    /// returns the number of sections. Always returns 1.
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    
    /// Returns the number of files in the section.
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    /// Allow edit rows? Returns true only if there are files.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return gpxFilesFound
    }
    
    /// Displays the delete button.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    /// Displays the name of the cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if gpxFilesFound {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            // swiftlint:disable:next force_cast
            let gpxFileInfo = fileList.object(at: (indexPath as NSIndexPath).row) as! GPXFileInfo
            let lastSaved = NSLocalizedString("LAST_SAVED", comment: "no comment")
            cell.textLabel?.text = gpxFileInfo.fileName
            cell.detailTextLabel?.text = String(format: lastSaved, gpxFileInfo.modifiedDatetimeAgo, gpxFileInfo.fileSizeHumanised)
            if #available(iOS 13, *) {
                cell.detailTextLabel?.textColor = UIColor.secondaryLabel
            } else {
                cell.detailTextLabel?.textColor = UIColor.darkGray
            }
            return cell
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
            return cell
        }
    }
    
    /// Displays an action sheet with the actions for that file (Send it by email, Load in map and Delete).
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sheet = UIAlertController(title: nil, message: NSLocalizedString("SELECT_OPTION", comment: "no comment"), preferredStyle: .actionSheet)
        let mapOption = UIAlertAction(title: NSLocalizedString("LOAD_IN_MAP", comment: "no comment"), style: .default) { _ in
            self.actionLoadFileAtIndex(indexPath.row)
        }
        let shareOption = UIAlertAction(title: NSLocalizedString("SHARE", comment: "no comment"), style: .default) { _ in
            self.actionShareFileAtIndex(indexPath.row, tableView: tableView, indexPath: indexPath)
        }
        
        let cancelOption = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"), style: .cancel) { _ in
            self.actionSheetCancel(sheet)
        }
        
        let deleteOption = UIAlertAction(title: NSLocalizedString("DELETE", comment: "no comment"), style: .destructive) { _ in
            self.actionDeleteFileAtIndex(indexPath.row)
        }
        
        sheet.addAction(mapOption)
        sheet.addAction(shareOption)
        sheet.addAction(cancelOption)
        sheet.addAction(deleteOption)
        
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect.origin = CGPoint(x: 0, y: 0) // origin must be at 0 or sheet will display offset due to height of cell
        
        sheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        sheet.popoverPresentationController?.sourceRect = cellRect
        
        self.present(sheet, animated: true) {
            print("Loaded actionSheet")
        }
    }
    
    // MARK: UITableView delegate methods
    
    /// Only highlight rows if there are files.
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return gpxFilesFound
    }
    
    /// Returns the name of the file in the `rowIndex` passed as parameter.
    internal func fileListObjectTitle(_ rowIndex: Int) -> String {
        // swiftlint:disable:next force_cast
        return (fileList.object(at: rowIndex) as! GPXFileInfo).fileName
    }
    
    //
    // MARK: Action Sheet - Actions
    //
    
    /// Cancel button is tapped.
    ///
    /// Does nothing, it only displays a log message.
    internal func actionSheetCancel(_ actionSheet: UIAlertController) {
        print("ActionSheet cancel")
    }
    
    /// Deletes from the disk storage the file of `fileList` at `rowIndex`.
    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        
        guard let fileURL: URL = (fileList.object(at: rowIndex) as? GPXFileInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionDeleteFileAtIndex: failed to get fileURL")
            return
        }
        GPXFileManager.removeFileFromURL(fileURL)
        
        // Delete from list and Table
        fileList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    /// Given a GPX file loads the file in the
    func loadGPXFile(gpxFileURL: URL) {

        self.displayLoadingFileAlert(true)
        DispatchQueue.global(qos: .userInitiated).async {
            print("GPXFIlesTableViewController:: loadGPXFile Load gpx File: \(gpxFileURL)")
            if GPXFileManager.GPXFilesFolderURL.startAccessingSecurityScopedResource() {
                defer {
                    GPXFileManager.GPXFilesFolderURL.stopAccessingSecurityScopedResource()
                }
                do {
                    DispatchQueue.main.sync {
                        self.displayLoadingFileAlert(true)
                    }
                    guard let gpx = GPXParser(withURL: gpxFileURL)?.parsedData() else {
                        print("GPXFileTableViewController:: load of GPX file failed")
                        DispatchQueue.main.sync {
                            Toast.error("Could not open file")
                            self.displayLoadingFileAlert(false)
                        }
                        return
                    }
                    DispatchQueue.main.sync {
                        self.displayLoadingFileAlert(false) {
                            self.delegate?.didLoadGPXFileWithName(gpxFileURL.deletingPathExtension().lastPathComponent, gpxRoot: gpx)
                            self.dismiss(animated: true, completion: nil)
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("Could not access folder: \(GPXFileManager.GPXFilesFolderURL)")
                DispatchQueue.main.sync {
                    Toast.error("Could not open file")
                    self.displayLoadingFileAlert(false)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
            
    /// Loads the GPX file that corresponds to rowIndex in fileList in the map.
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
        guard let gpxFileInfo: GPXFileInfo = (self.fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to get fileURL")
            return
        }
        print("GPXFileTableViewController:: Load gpx File: \(gpxFileInfo.fileName)")
        print("GPXFileTableViewController:: Load gpx URL: \(gpxFileInfo.fileURL)")
        loadGPXFile(gpxFileURL: gpxFileInfo.fileURL)
    }
    
    /// Displays an alert with a activity indicator view to indicate loading of gpx file to map
    func displayLoadingFileAlert(_ loading: Bool, completion: (() -> Void)? = nil) {
        // setup of controllers and views
        let alertController = UIAlertController(title: NSLocalizedString("LOADING_FILE", comment: "no comment"), message: nil, preferredStyle: .alert)
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 35, y: 30, width: 32, height: 32))
        activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicatorView.style = .whiteLarge
        
        if #available(iOS 13, *) {
            activityIndicatorView.color = .blackAndWhite
        } else {
            activityIndicatorView.color = .black
        }
        
        if loading { // will display alert
            activityIndicatorView.startAnimating()
            alertController.view.addSubview(activityIndicatorView)
            
            self.present(alertController, animated: true, completion: nil)
        } else { // will dismiss alert
            activityIndicatorView.stopAnimating()
            //self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        // if completion handler is used
        guard let completion = completion else { return }
        completion()
    }
    
    /// Shares file at `rowIndex`.
    internal func actionShareFileAtIndex(_ rowIndex: Int, tableView: UITableView, indexPath: IndexPath) {
        guard let gpxFileInfo: GPXFileInfo = (fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("Unable to get filename at row \(rowIndex), cannot respond to \(type(of: self))didSelectRowAt")
            return
        }
        print("GPXTableViewController: actionShareFileAtIndex")
        
        let activityViewController = UIActivityViewController(activityItems: [gpxFileInfo.fileURL], applicationActivities: nil)
        
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect.origin = CGPoint(x: 0, y: 0) // origin must be at 0 or sheet will display offset due to height of cell
        
        activityViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        activityViewController.popoverPresentationController?.sourceRect = cellRect
        
        // NOTE: As the activity view controller can be quite tall at times,
        //       the display of it may be offset automatically at times to ensure the activity view popup fits the screen.
        
        activityViewController.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                print("actionShareAtIndex: Cancelled")
                return
            }
            // User completed activity
            print("actionShareFileAtIndex: User completed activity")
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    /// When the user selects the
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            print("GPXFilesTableViewController: documentPicker: User didn't select any folder")
            return
        }
        // Update preferences and folder
        print("GPXFilesTableViewController: documentPicker:  selected URL \(selectedURL)")
        
        // If the selected url is a GPX file, then open the GPX File
        if GPXFileManager.gpxExtList.contains(selectedURL.pathExtension) {
            print("GPXFilesTableViewController: documentPicker: elected URL is a GPX File. Loading it")
            loadGPXFile(gpxFileURL: selectedURL)
            return
        }
        // it is a path -> we mark it as the preference folder.
        Preferences.shared.gpxFilesFolderURL = selectedURL
        
        folderLabel.text = selectedURL.lastPathComponent
        reloadTableData()
    }
    
    ///
    /// Asks the system to notify the app on some events
    ///
    /// Current implementation requests the system to notify the app:
    ///
    ///  When a file is received from an external source, (i.e AirDrop)
    ///
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(reloadTableData),
                                       name: .didReceiveFileFromURL, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reloadTableData), name: .didReceiveFileFromAppleWatch, object: nil)
    }
    
    ///
    /// Reload Table View data
    ///
    /// For reloading the tableView in `GPXFileTableViewController`
    ///
    /// It gets from the `GPXFileManager` the`fileList`
    ///
    ///
    @objc func reloadTableData() {
        print("TableViewController: reloadTableData")
        let list: [GPXFileInfo] = GPXFileManager.fileList
        fileList.removeAllObjects()
        gpxFilesFound = list.count > 0
        if (gpxFilesFound) {
            fileList.addObjects(from: list)
        } else {
            fileList.addObjects(from: [kNoFiles])
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
