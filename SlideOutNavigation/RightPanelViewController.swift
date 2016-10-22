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
    func userLocketSelected(_ userLocket: UserLocketEntity)
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
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Add 1 to the number of lockets to show the "AddNewCell"
        return SettingsManager.sharedManager.userLockets.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath as NSIndexPath).row < SettingsManager.sharedManager.userLockets.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.LocketCell, for: indexPath) as! UserLocketCell
            
            let locket = SettingsManager.sharedManager.userLockets[(indexPath as NSIndexPath).row]
            cell.configureForLocket(locket)
            
            if SettingsManager.sharedManager.isUserLocketSelected((indexPath as NSIndexPath).row) == true {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            }
            
            return cell
        // Exception for the "New" cell which adds lockets
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.AddNewCell, for: indexPath)
            
            return cell
        }
    }
    
}

// Mark: Table View Delegate

extension RightPanelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row < SettingsManager.sharedManager.userLockets.count {
            let selectedLocket = SettingsManager.sharedManager.selectUserLocket((indexPath as NSIndexPath).row)
            AnalyticsManager.sharedManager.userLocketSelectAction("Lckt #\((indexPath as NSIndexPath).row), cap: \(selectedLocket.caption_text), skin: \(selectedLocket.locket_skin.title)")
            delegate?.userLocketSelected(selectedLocket)
        } else {
            let selectedLocket = SettingsManager.sharedManager.addNewLocket()
            AnalyticsManager.sharedManager.valueChangedEvent("Saved Lockets", action: "Add New Locket", value: SettingsManager.sharedManager.userLockets.count)
            delegate?.userLocketSelected(selectedLocket)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).row < SettingsManager.sharedManager.userLockets.count {
            return !SettingsManager.sharedManager.isUserLocketSelected((indexPath as NSIndexPath).row)
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            SettingsManager.sharedManager.deleteUserLocket((indexPath as NSIndexPath).row )
            AnalyticsManager.sharedManager.valueChangedEvent("Saved Lockets", action: "Delete Locket", value: SettingsManager.sharedManager.userLockets.count)
            tableView.reloadData()
        }
    }
    
}
