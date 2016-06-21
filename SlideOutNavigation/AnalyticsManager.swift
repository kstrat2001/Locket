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
    
    private (set) var tracker : GAITracker?
    
    private init() {
        tracker = nil
    }
    
    func initTracker(name: String, trackingId: String) {
        // Configure tracker from GoogleService-Info.plist.
        self.tracker = GAI.sharedInstance().trackerWithName(name, trackingId: trackingId)
    }
    
    func appEvent(action: String) {
        self.baseEvent("App", action: action, label: "app", value: nil)
    }
    
    func selectionEvent(action: String) {
        self.baseEvent("Selection", action: action, label: "selection", value: nil)
    }
    
    func locketSkinSelectAction(action: String) {
        self.baseEvent("Locket Skin Selection", action: action, label: "selection", value: nil)
    }
    
    func userLocketSelectAction(action: String) {
        self.baseEvent("User Locket Selection", action: action, label: "selection", value: nil)
    }
    
    func settingsEvent(action: String) {
        self.baseEvent("Settings", action: action, label: "settings", value: nil)
    }
    
    func valueChangedEvent(category: String, action:String, value: NSNumber) {
        self.baseEvent(category, action: action, label: "value", value: value)
    }
    
    private func baseEvent(category: String, action: String, label: String, value: NSNumber?) {
        let dict : NSMutableDictionary = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build()
        self.tracker?.send(dict as [NSObject : AnyObject])
    }
}