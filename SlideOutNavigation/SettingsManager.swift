//
//  SettingsManager.swift
//  Locket
//
//  Created by Kain Osterholt on 2/21/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation

class SettingsManager
{
    static let sharedManager = SettingsManager()
    
    private (set) var userLockets : [UserLocket] = Array<UserLocket>()
    private (set) var selectedLocket : UserLocket?
    
    init()
    {
        
    }
    
    func loadUserLockets()
    {
        // TODO: currently this runs as if it's always the first app open
        // need to update this load user lockets with core data
        
        self.userLockets.append(UserLocket.createDefaultUserLocket())
        
        self.selectedLocket = self.userLockets[0]
    }
}