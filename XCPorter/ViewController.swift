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
    
    struct ProvisioningProfile {
        let name: String
        let expiryDate: NSDate
        let team: String
        var appID: String?
        
        init?(path: String) {
            
            guard let data = NSFileManager.defaultManager().contentsAtPath(path) else {
                return nil
            }
            
            guard let stringData = String(data: data, encoding:NSISOLatin1StringEncoding) else {
                return nil
            }
            
            let scanner = NSScanner(string: stringData)
            var scanned: NSString?
            scanner.scanUpToString("<plist version", intoString: nil)
            scanner.scanUpToString("</plist>", intoString: &scanned)
            
            guard let scannedPlist = scanned else {
                return nil
            }
            
            let plistString: NSString = "\(scannedPlist)</plist>"
            
            guard let plist = plistString.propertyList() as? [String: AnyObject] else {
                return nil
            }
            self.name = plist["Name"] as! String
            self.expiryDate = plist["ExpirationDate"] as! NSDate
            self.team = plist["TeamName"] as! String
            
            if let entitlements = plist["Entitlements"] as? [String: AnyObject] {
                self.appID = entitlements["application-identifier"] as? String
            }
        }
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
        exportButton.enabled = false
    
        guard let p = createProfiles() else {
            return
        }
        
        allProfiles = p
        
        tableView.setDataSource(self)
        tableView.reloadData()
    }


}

extension ViewController {

    func chooseFile() {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["xcarchive"]
        panel.allowsMultipleSelection = false
        panel.directoryURL = NSURL(string: "file:\(archiveRoot)")
        
        if panel.runModal() == NSModalResponseOK {
            archivePath.stringValue = panel.URLs.first?.lastPathComponent ?? ""
            
            exportButton.enabled = true
        }
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
}

extension ViewController {
    
    @IBAction func openClicked(sender: NSButton) {
        chooseFile()
    }
    
    @IBAction func exportClicked(sender: NSButton) {
        
    }
}

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

