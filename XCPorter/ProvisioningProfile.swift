//
//  ProvisioningProfile.swift
//  XCPorter
//
//  Created by Max Chuquimia on 5/12/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import Foundation

struct ProvisioningProfile {
    let name: String
    let expiryDate: NSDate
    let team: String
    var appID: String?
    
    init?(path: String) {
        
        guard let plist = PlistParser.from(path) else {
            return nil
        }
        
        self.name = plist["Name"] as! String
        self.expiryDate = plist["ExpirationDate"] as! NSDate
        self.team = (plist["TeamName"] as? String) ?? ""
        
        if let entitlements = plist["Entitlements"] as? [String: AnyObject] {
            self.appID = entitlements["application-identifier"] as? String
        }
    }
}
