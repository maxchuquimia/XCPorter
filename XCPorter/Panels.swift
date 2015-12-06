//
//  Panels.swift
//  XCPorter
//
//  Created by Max Chuquimia on 5/12/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import Foundation
import Cocoa

extension NSOpenPanel {
    
    /*!
    Allows the user to pick an XCArchive package
    
    - parameter archiveRoot: the default root of all the archives
    
    - returns: an `NSURL` of an archive if the user selected one, or `nil` if they cancelled
    */
    class func archiveURL(archiveRoot: String) -> NSURL? {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["xcarchive"]
        panel.allowsMultipleSelection = false
        panel.directoryURL = NSURL(string: "file:\(archiveRoot)")
        
        if panel.runModal() == NSModalResponseOK {
            return panel.URLs.first
        }
        
        return nil
    }
    
    
    /*!
    Allows the user to pick a directory
    
    - returns: an `NSURL` of a directory if the user selected one, or `nil` if they cancelled
    */
    class func anyDirectory() -> NSURL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = NSURL(string: ("~/Desktop" as NSString).stringByExpandingTildeInPath)
        
        if panel.runModal() == NSModalResponseOK {
            return panel.URLs.first
        }
        
        return nil
    }
}

extension NSAlert {
    
    class func questionAlert(title: String, message: String) -> Bool {
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
    
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        
        return alert.runModal() == NSAlertFirstButtonReturn
    }
}
