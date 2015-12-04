//
//  AppDelegate.swift
//  XCPorter
//
//  Created by Max Chuquimia on 3/12/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import Cocoa

protocol MenuActionsDelegate: class {
    
    /*!
    The user wants to open an archive
    */
    func menuActionArchiveOpen()
    
    /*!
    The user wants to export an archive to the default location
    */
    func menuActionSaveArchive()
    
    /*!
    The user wants to export an archive and select a location
    */
    func menuActionSaveArchiveAs()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    weak var menuDelegate: MenuActionsDelegate?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }
}

extension AppDelegate {
    
    @IBAction func openArchive(sender: NSMenuItem) {
        menuDelegate?.menuActionArchiveOpen()
    }
    
    @IBAction func saveArchive(sender: NSMenuItem) {
        menuDelegate?.menuActionSaveArchive()
    }
    
    @IBAction func saveArchiveAs(sender: NSMenuItem) {
        menuDelegate?.menuActionSaveArchiveAs()
    }
}
