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
    
    var selectedLocket : UserLocketEntity {
        return self.user.selected_locket!
    }
    
    fileprivate (set) var userLockets : [UserLocketEntity]! = [UserLocketEntity]()
    fileprivate (set) var user : UserEntity!
    
    init()
    {
        self.user = UserEntity.fetch()
        
        if self.user == nil {
            self.user = UserEntity.create()
        }
        
        self.userLockets = UserLocketEntity.fetchAll()
        
        if self.userLockets.count == 0 {
            let first_user_locket = UserLocketEntity.createWithData(gDefaultUserLocketData)
            self.userLockets.append(first_user_locket)
            self.user.selected_locket = first_user_locket
        } else if self.user.selected_locket == nil {
            self.user.selected_locket = self.userLockets[0]
        }
        
        DataManager.sharedManager.saveAllRecords()
    }
    
    func addNewLocket() -> UserLocketEntity
    {
        let locket = UserLocketEntity.createWithData(gDefaultUserLocketData)
        self.userLockets.append(locket)
        self.user.selected_locket = locket
        DataManager.sharedManager.saveAllRecords()
        return locket
    }
    
    func selectUserLocket(_ index: Int) -> UserLocketEntity {
        self.user.selected_locket = self.userLockets[index]
        DataManager.sharedManager.saveAllRecords()
        return selectedLocket;
    }
    
    func isUserLocketSelected(_ index: Int) -> Bool {
        return selectedLocket == self.userLockets[index]
    }
    
    func deleteUserLocket(_ index: Int) {
        DataManager.sharedManager.deleteRecord(self.userLockets[index])
        self.userLockets = UserLocketEntity.fetchAll()
    }
    
    func locketSkinInUse(_ locketSkin: LocketSkinEntity) -> Bool {
        for userLocket in self.userLockets {
            if userLocket.locket_skin == locketSkin {
                return true;
            }
        }
        
        return false;
    }
}
