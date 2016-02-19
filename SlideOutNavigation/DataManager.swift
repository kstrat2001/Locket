//
//  DataManager.swift
//  Locket
//
//  Created by Kain Osterholt on 2/11/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import Alamofire

class DataManager
{
    static let sharedManager = DataManager()
    private (set) var lockets = Array<Locket>()
    
    private init()
    {
        
    }
    
    func loadAppData()
    {
        Alamofire.request(.GET, "http://api.mobilelocket.com/lockets").responseJSON()
        {
            response in
            
            switch response.result
            {
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                case .Success(let JSON):
                    let response = JSON as! NSDictionary
                    self.lockets = Locket.loadLockets(response)
            }
        }
    }
}