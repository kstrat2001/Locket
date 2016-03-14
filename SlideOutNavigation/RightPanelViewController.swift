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
        return SettingsManager.sharedManager.userLockets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.LocketCell, forIndexPath: indexPath) as! UserLocketCell
        
        let locket = SettingsManager.sharedManager.userLockets[indexPath.row]
        cell.configureForLocket(locket)
        return cell
    }
    
}

// Mark: Table View Delegate

extension RightPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedLocket = SettingsManager.sharedManager.userLockets[indexPath.row]
        delegate?.userLocketSelected(selectedLocket)
    }
    
}