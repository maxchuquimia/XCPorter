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
        }
    }
    
    func reloadExportButton() {
        exportButton.enabled = (selectedArchivePath != nil)
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
        save("default path")
    }
    
    func menuActionSaveArchiveAs() {
        saveAs()
    }
}

// MARK: - Saving
extension ViewController {
    
    func saveAs() {
        
    }
    
    func save(path: String) {
        
        let command = "sleep 2; echo hello"
        
        if terminalCheckbox.state == NSOnState {
            runCommandInTerminal(command)
        }
        else {
            runCommand(command)
        }
    }
    
    func runCommandInTerminal(command: String) {
        
        let applescript = "tell application \"Terminal\" to do script \"\(command)\""
        
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

