//
//  PlistParser.swift
//  XCPorter
//
//  Created by Max Chuquimia on 5/12/2015.
//  Copyright © 2015 Chuquimian Productions. All rights reserved.
//

import Foundation

class PlistParser {
    
    class func from(path: String) -> [String: AnyObject]? {
     
        guard let data = NSFileManager.defaultManager().contentsAtPath(path) else {
            return nil
        }
        
        guard let stringData = String(data: data, encoding: NSISOLatin1StringEncoding) else {
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

        return plistString.propertyList() as? [String: AnyObject]
    }
}