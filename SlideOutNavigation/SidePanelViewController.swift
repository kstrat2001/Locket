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
    func locketSkinSelected(skin: LocketSkinEntity)
}

class SidePanelViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var delegate: SidePanelViewControllerDelegate?
  
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
        return DataManager.sharedManager.locketSkins.count
    }
  
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.LocketCell, forIndexPath: indexPath) as! LocketCell
        let entity = DataManager.sharedManager.locketSkins[indexPath.row]
        cell.configureForLocket(entity)
        return cell
    }
  
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedEntity = DataManager.sharedManager.locketSkins[indexPath.row]
    delegate?.locketSkinSelected(selectedEntity)
  }
}