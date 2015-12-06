//
//  PersistantCheckbox.swift
//  XCPorter
//
//  Created by Max Chuquimia on 5/12/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import Foundation
import Cocoa

class PersistantCheckbox: NSButton {
    
    /// To be set in the runtime attributes
    var persistantIdentifier: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let value = NSUserDefaults.standardUserDefaults().boolForKey(persistantIdentifier)
    
        state = value ? NSOnState : NSOffState
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistValue", name: NSApplicationWillTerminateNotification, object: nil)
    }
    
    func persistValue() {
        NSUserDefaults.standardUserDefaults().setBool(state == NSOnState, forKey: persistantIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}


