//
//  LeftViewController.swift
//  SlideOutNavigation
//
//  Created by Kain Osterholt on 03/08/2014.
//  Copyright (c) 2014 Kain Osterholt. All rights reserved.
//

import UIKit

protocol SidePanelViewControllerDelegate
{
    func locketSelected(locket: Locket)
}

class SidePanelViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var delegate: SidePanelViewControllerDelegate?

  var lockets: Array<Locket>?
  
  struct TableView {
    struct CellIdentifiers {
      static let LocketCell = "LocketCell"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.reloadData()
  }
  
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
  
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (lockets != nil)
        {
            return lockets!.count
        }
        
        return 0
    }
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.LocketCell, forIndexPath: indexPath) as! LocketCell
        cell.configureForLocket(lockets![indexPath.row])
        return cell
    }
  
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedRow = lockets![indexPath.row]
    delegate?.locketSelected(selectedRow)
  }
  
}