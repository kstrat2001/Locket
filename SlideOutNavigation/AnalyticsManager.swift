//
//  AnalyticsManager.swift
//  Locket
//
//  Created by Kain Osterholt on 5/28/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation

class AnalyticsManager
{
    static let sharedManager = AnalyticsManager()
    
    fileprivate (set) var tracker : GAITracker?
    
    fileprivate init() {
        tracker = nil
    }
    
    func initTracker(_ name: String, trackingId: String) {
        // Configure tracker from GoogleService-Info.plist.
        self.tracker = GAI.sharedInstance().tracker(withName: name, trackingId: trackingId)
    }
    
    func appEvent(_ action: String) {
        self.baseEvent("App", action: action, label: "app", value: nil)
    }
    
    func selectionEvent(_ action: String) {
        self.baseEvent("Selection", action: action, label: "selection", value: nil)
    }
    
    func locketSkinSelectAction(_ action: String) {
        self.baseEvent("Locket Skin Selection", action: action, label: "selection", value: nil)
    }
    
    func userLocketSelectAction(_ action: String) {
        self.baseEvent("User Locket Selection", action: action, label: "selection", value: nil)
    }
    
    func settingsEvent(_ action: String) {
        self.baseEvent("Settings", action: action, label: "settings", value: nil)
    }
    
    func valueChangedEvent(_ category: String, action:String, value: NSNumber) {
        self.baseEvent(category, action: action, label: "value", value: value)
    }
    
    fileprivate func baseEvent(_ category: String, action: String, label: String, value: NSNumber?) {
        let dict : NSMutableDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build()
        self.tracker?.send(dict as [AnyHashable: Any])
    }
}
