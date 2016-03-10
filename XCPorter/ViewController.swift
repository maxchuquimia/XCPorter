//
//  ViewController.swift
//  XCPorter
//
//  Created by Max Chuquimia on 3/12/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet private weak var dSYMCheckbox: NSButton!
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var exportButton: NSButton!
    @IBOutlet private weak var openButton: NSButton!
    @IBOutlet private weak var terminalCheckbox: NSButton!
    @IBOutlet private weak var archivePath: NSTextField!
    @IBOutlet private weak var progress: NSProgressIndicator!
    private var allProfiles = [ProvisioningProfile]()
    private var selectedArchivePath: String?
    private var selectedProfileName: String? {
        
        guard self.tableView.selectedRow > -1 else {
            return nil
        }
        
        return allProfiles[self.tableView.selectedRow].name
    }
    
    
    var archiveRoot: NSString {
        let path: NSString = "~/Library/Developer/Xcode/Archives/"
        return path.stringByExpandingTildeInPath
    }
    
    var profilesPath: NSString {
        let path: NSString = "~/Library/MobileDevice/Provisioning Profiles/"
        return path.stringByExpandingTildeInPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadExportButton()
    
        guard let p = createProfiles() else {
            return
        }
        
        allProfiles = p
        
        tableView.setDataSource(self)
        tableView.reloadData()
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.menuDelegate = self
    }
}

extension ViewController {

    func chooseFile() {
        
        guard let url = NSOpenPanel.archiveURL(archiveRoot as String) else {
            return
        }
        
        selectedArchivePath = url.absoluteString
        archivePath.stringValue = url.lastPathComponent!

        reloadExportButton()
    }
    
    func createProfiles() -> [ProvisioningProfile]? {
        
        let fileManager = NSFileManager.defaultManager()
        
        return try? fileManager.contentsOfDirectoryAtPath(profilesPath as String).filter { (path) -> Bool in
            return path.hasSuffix(".mobileprovision")
        }
        .flatMap { (path) -> ProvisioningProfile? in
            
            let fullPath = profilesPath.stringByAppendingPathComponent(path)
            return ProvisioningProfile(path: fullPath)
        }.sort({ (a, b) -> Bool in
            return a.name < b.name
        })
    }
    
    func reloadExportButton() {
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        
        exportButton.enabled = (selectedArchivePath != nil) && (selectedProfileName != nil)
        appDelegate.enableSaving = exportButton.enabled
    }
}

// MARK: - IB Actions
extension ViewController {
    
    @IBAction func openClicked(sender: NSButton) {
        chooseFile()
    }
    
    @IBAction func exportClicked(sender: NSButton) {
        menuActionSaveArchive()
    }
}

// MARK: - MenuActionsDelegate
extension ViewController: MenuActionsDelegate {
    
    func menuActionArchiveOpen() {
        chooseFile()
    }
    
    func menuActionSaveArchive() {
        
        if !exportButton.enabled {
            return; //hack
        }
        
        // say `as NSString` one more time...
        let savePath = (("~/Desktop" as NSString).stringByExpandingTildeInPath as NSString).stringByAppendingPathComponent((selectedArchivePath! as NSString).lastPathComponent)
        save(pathWithoutExtension: savePath)
    }
    
    func menuActionSaveArchiveAs() {
        
        if !exportButton.enabled {
            return; //same hack
        }
        
        saveAs()
    }
}

// MARK: - Saving
extension ViewController {
    
    func pathWithoutExtensionByAddingFilename(directory: String) -> String {
        
        let nspath = directory as NSString
        return nspath.stringByAppendingPathComponent(archivePath.stringValue).stringByReplacingOccurrencesOfString("xcarchive", withString: "")
    }
    
    func saveAs() {
        
        guard let dir = NSOpenPanel.anyDirectory() else {
            return
        }
        
        let path = pathWithoutExtensionByAddingFilename(dir.absoluteString)
        save(pathWithoutExtension: path)
    }
    
    //Sample command: xcodebuild -exportArchive -archivePath "path to archive"  -exportFormat ipa -exportProvisioningProfile "Profile Name" -exportPath "output path"
    func save(pathWithoutExtension path: NSString) {
        
        let ipaPath = path.stringByAppendingPathExtension("ipa")!
        let testPath = (ipaPath as NSString).stringByRemovingPercentEncoding!
        
        if NSFileManager.defaultManager().fileExistsAtPath(testPath) {
            
            if !NSAlert.questionAlert("An IPA with the same name exists at the chosen path", message: "Would you like to continue and overwrite it?") {
                return
            }
            
            try! NSFileManager.defaultManager().removeItemAtPath(testPath)
        }
        
        var command = "xcodebuild -exportArchive -archivePath \"\(selectedArchivePath!)\" -exportFormat ipa -exportProvisioningProfile \"\(selectedProfileName!)\" -exportPath \"\(ipaPath)\""
        
        if dSYMCheckbox.state == NSOnState {
        
            if let dSYMCommand = dSYMsExportCommand(path as String) {
                command.appendContentsOf(dSYMCommand)
            }
        }
        
        command.appendContentsOf("; open -R \"\(ipaPath)\"")
        command = command.stringByReplacingOccurrencesOfString("file://", withString: "").stringByReplacingOccurrencesOfString("file:", withString: "").stringByRemovingPercentEncoding! //'cos why not
        
        print(command)
        
        if terminalCheckbox.state == NSOnState {
            runCommandInTerminal(command)
        }
        else {
            runCommand(command)
        }
    }
    
    func dSYMsExportCommand(exportDirectory: String) -> String? {
        
        var dSYMDir: NSString = (selectedArchivePath! as NSString).stringByAppendingPathComponent("dSYMs")
        
        //why is this different?
        dSYMDir = dSYMDir.stringByReplacingOccurrencesOfString("file:", withString: "").stringByRemovingPercentEncoding!
        
        return try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(dSYMDir as String).filter({ (path) -> Bool in
            return path.hasSuffix(".dSYM")
        }).reduce("; cd \"\(dSYMDir)\"", combine: { (full, new) -> String in
            
            let thisOutpath = "\(exportDirectory)-\(new).zip"
            return "\(full); zip -FSr \"\(thisOutpath)\" \"\(new)\""
        })
    }
    
    func runCommandInTerminal(command: String) {
        
        var command = command
        
        NSAppleScript(source: "tell application \"Terminal\" to active")?.executeAndReturnError(nil)
        
        command = command.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        
        let applescript = "tell application \"Terminal\" to do script \"\(command)\"" // single quotes, Larry
        
        let osascript = NSAppleScript(source: applescript)
        
        osascript?.executeAndReturnError(nil)
    }
    
    func runCommand(command: String) {
        
        print("start")

        exportButton.enabled = false
        progress.startAnimation(self)
        
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
        
        task.waitUntilExit()
        
        print("end", task.terminationStatus)
        
        exportButton.enabled = true
        progress.stopAnimation(self)
    }
}

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return allProfiles.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let profile = allProfiles[row]
        
        if tableColumn?.title == "Profile Name" {
            return profile.name
        }
        else if tableColumn?.title == "Expiry Date" {
            return profile.expiryDate
        }
        else if tableColumn?.title == "Team" {
            return profile.team
        }
        else if tableColumn?.title == "Bundle" {
            return profile.appID
        }
        
        return nil
    }
}

