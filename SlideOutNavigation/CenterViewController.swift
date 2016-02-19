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
        
        self.view.addSubview(locketView!)
    }
}

extension CenterViewController: SidePanelViewControllerDelegate
{
    func locketSelected(locket: Locket)
    {
        locketView?.setLocket(locket)
        
        delegate?.collapseSidePanels?()
    }
}