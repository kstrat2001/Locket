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
    func locketSkinSelected(_ skin: LocketSkinEntity)
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
  
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return DataManager.sharedManager.locketSkins.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.LocketCell, for: indexPath) as! LocketCell
        let entity = DataManager.sharedManager.locketSkins[(indexPath as NSIndexPath).row]
        cell.configureForLocket(entity)
        return cell
    }
  
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedEntity = DataManager.sharedManager.locketSkins[(indexPath as NSIndexPath).row]
    AnalyticsManager.sharedManager.locketSkinSelectAction("Selected skin: \(selectedEntity.title)")
    delegate?.locketSkinSelected(selectedEntity)
  }
}
