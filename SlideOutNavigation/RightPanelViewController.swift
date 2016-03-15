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
            
            return cell
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
            let selectedLocket = SettingsManager.sharedManager.userLockets[indexPath.row]
            delegate?.userLocketSelected(selectedLocket)
        } else {
            let selectedLocket = SettingsManager.sharedManager.addNewLocket()
            delegate?.userLocketSelected(selectedLocket)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row < SettingsManager.sharedManager.userLockets.count {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserLocketCell
            cell.layer.borderColor = UIColor.blackColor().CGColor
            cell.layer.borderWidth = 2
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row < SettingsManager.sharedManager.userLockets.count {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserLocketCell
            cell.layer.borderColor = UIColor.clearColor().CGColor
            cell.layer.borderWidth = 0
        }
        
        return indexPath
    }
    
}