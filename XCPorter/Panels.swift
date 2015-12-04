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
    
    class func archiveURL(archiveRoot: String) -> NSURL? {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["xcarchive"]
        panel.allowsMultipleSelection = false
        panel.directoryURL = NSURL(string: "file:\(archiveRoot)")
        
        if panel.runModal() == NSModalResponseOK {
            return panel.URLs.first
        }
        
        return nil
    }
}