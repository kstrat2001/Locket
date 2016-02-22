//
//  CenterViewController.swift
//  SlideOutNavigation
//
//  Created by Kain Osterholt on 03/08/2014.
//  Copyright (c) 2014 Kain Osterholt. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate
{
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class CenterViewController: UIViewController
{
    var delegate: CenterViewControllerDelegate?
    
    var locketView: LocketView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locketView = LocketView(frame: (self.view?.frame)!)
        locketView?.setUserLocket(SettingsManager.sharedManager.selectedLocket)
        
        self.view.addSubview(locketView!)
    }
}

extension CenterViewController: RightPanelViewControllerDelegate
{
    func userLocketSelected(locket: UserLocket) {
        locketView?.setUserLocket(locket)
    }
}

extension CenterViewController: SidePanelViewControllerDelegate
{
    func locketSelected(locket: Locket)
    {
        let userLocket = SettingsManager.sharedManager.selectedLocket!
        userLocket.setLocket(locket);
        
        locketView?.setUserLocket(userLocket)
        
        delegate?.collapseSidePanels?()
    }
}