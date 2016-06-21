//
//  RightPanelViewController.swift
//  Locket
//
//  Created by Kain Osterholt on 2/21/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

protocol RightPanelViewControllerDelegate
{
    func userLocketSelected(userLocket: UserLocketEntity)
}

class RightPanelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: RightPanelViewControllerDelegate?
    
    struct TableView {
        struct CellIdentifiers {
            static let LocketCell = "UserLocketCell"
            static let AddNewCell = "AddNewCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
        tableView.reloadData()

    }
}

// MARK: Table View Data Source

extension RightPanelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Add 1 to the number of lockets to show the "AddNewCell"
        return SettingsManager.sharedManager.userLockets.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.row < SettingsManager.sharedManager.userLockets.count {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.LocketCell, forIndexPath: indexPath) as! UserLocketCell
            
            let locket = SettingsManager.sharedManager.userLockets[indexPath.row]
            cell.configureForLocket(locket)
            
            if SettingsManager.sharedManager.isUserLocketSelected(indexPath.row) == true {
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
            
            return cell
        // Exception for the "New" cell which adds lockets
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.AddNewCell, forIndexPath: indexPath)
            
            return cell
        }
    }
    
}

// Mark: Table View Delegate

extension RightPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row < SettingsManager.sharedManager.userLockets.count {
            let selectedLocket = SettingsManager.sharedManager.selectUserLocket(indexPath.row)
            AnalyticsManager.sharedManager.userLocketSelectAction("Lckt #\(indexPath.row), cap: \(selectedLocket.caption_text), skin: \(selectedLocket.locket_skin.title)")
            delegate?.userLocketSelected(selectedLocket)
        } else {
            let selectedLocket = SettingsManager.sharedManager.addNewLocket()
            AnalyticsManager.sharedManager.valueChangedEvent("Saved Lockets", action: "Add New Locket", value: SettingsManager.sharedManager.userLockets.count)
            delegate?.userLocketSelected(selectedLocket)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row < SettingsManager.sharedManager.userLockets.count {
            return !SettingsManager.sharedManager.isUserLocketSelected(indexPath.row)
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            SettingsManager.sharedManager.deleteUserLocket(indexPath.row )
            AnalyticsManager.sharedManager.valueChangedEvent("Saved Lockets", action: "Delete Locket", value: SettingsManager.sharedManager.userLockets.count)
            tableView.reloadData()
        }
    }
    
}