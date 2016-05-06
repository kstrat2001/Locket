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
        selectedLocket = locket
        return locket
    }
    
    func selectUserLocket(index: Int) -> UserLocketEntity {
        selectedLocket = self.userLockets[index]
        return selectedLocket;
    }
    
    func isUserLocketSelected(index: Int) -> Bool {
        return selectedLocket == self.userLockets[index]
    }
    
    func deleteUserLocket(index: Int) {
        DataManager.sharedManager.deleteRecord(self.userLockets[index])
        self.userLockets = UserLocketEntity.fetchAll()
    }
    
    func locketSkinInUse(locketSkin: LocketSkinEntity) -> Bool {
        for userLocket in self.userLockets {
            if userLocket.locket_skin == locketSkin {
                return true;
            }
        }
        
        return false;
    }
}