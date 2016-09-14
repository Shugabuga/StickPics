//
//  Store.swift
//  StickPics
//
//  Created by Dylan Wight on 8/20/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class StickPicHistory {
    
    var stickPicURLs = [URL]()
    
    static let userDefaultsKey = "StickPicHistory"
    
    let prefs = UserDefaults()
    
    func addStickPicURL(url: URL) {
        stickPicURLs.append(url)
        save()
    }
    
    private init(stickPicURLs: [URL]) {
        self.stickPicURLs = stickPicURLs
    }
    
    /// Loads previously created `IceCream`s and returns a `IceCreamHistory` instance.
    static func load() -> StickPicHistory {
        var stickPicURLs = [URL]()
        let defaults = UserDefaults.standard
        
        
        if let savedStickPics = defaults.object(forKey: StickPicHistory.userDefaultsKey) as? [String] {
            print(savedStickPics.description)
            stickPicURLs = savedStickPics.flatMap { urlString in
                return URL(string: urlString)
            }
        }
        
        return StickPicHistory(stickPicURLs: stickPicURLs)
    }
    
    /// Saves the history.
    func save() {
        // Save a maximum number ice creams.
        let stickPicsToSave = stickPicURLs //.suffix(8)
        
        // Map the ice creams to an array of URL strings.
        let stickPicURLStrings: [String] = stickPicsToSave.flatMap { stickPic in
            return stickPic.absoluteString
        }
        
        let defaults = UserDefaults.standard
        defaults.set(stickPicURLStrings as AnyObject, forKey: StickPicHistory.userDefaultsKey)
    }
}


