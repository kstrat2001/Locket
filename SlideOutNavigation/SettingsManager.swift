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
    
    private (set) var userLockets : [UserLocketEntity]! = [UserLocketEntity]()
    private (set) var selectedLocket : UserLocketEntity!
    
    init()
    {
        self.userLockets = UserLocketEntity.fetchAll()
        
        if self.userLockets.count == 0 {
            self.userLockets.append(UserLocketEntity.createWithData(gDefaultUserLocketData))
        }
        
        self.selectedLocket = self.userLockets[0]
    }
    
    func addNewLocket() -> UserLocketEntity
    {
        let locket = UserLocketEntity.createWithData(gDefaultUserLocketData)
        self.userLockets.append(locket)
        return locket
    }
}