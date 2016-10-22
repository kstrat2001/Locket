//
//  ContainerViewController.swift
//  SlideOutNavigation
//
//  Created by Kain Osterholt on 03/08/2014.
//  Copyright (c) 2014 Kain Osterholt. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState
{
    case bothCollapsed
    case leftPanelExpanded
    case rightPanelExpanded
}

class ContainerViewController: UIViewController
{
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!

    var currentState: SlideOutState = .bothCollapsed
    {
        didSet
        {
          let shouldShowShadow = currentState != .bothCollapsed
          showShadowForCenterViewController(shouldShowShadow)
        }
    }

    var leftViewController: SidePanelViewController?
    var rightViewController: RightPanelViewController?

    let centerPanelExpandedOffset: CGFloat = 60
    
    // For enabling and disabling the sliding menus
    fileprivate (set) var slidePanelsEnabled: Bool = true

    override func viewDidLoad()
    {
        super.viewDidLoad()

        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self

        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)

        centerNavigationController.didMove(toParentViewController: self)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        centerNavigationController.isNavigationBarHidden = true
    }
  
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate
{
    func enableSlidePanels(_ enable: Bool) {
        self.slidePanelsEnabled = enable
    }
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
    
        if notAlreadyExpanded
        {
            addLeftPanelViewController()
        }
    
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
  
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)
    
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
    
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
  
    func collapseSidePanels() {
        switch (currentState)
        {
            case .rightPanelExpanded:
              toggleRightPanel()
            case .leftPanelExpanded:
              toggleLeftPanel()
            default:
              break
        }
    }
  
    func addLeftPanelViewController() {
        if (leftViewController == nil)
        {
            leftViewController = UIStoryboard.leftViewController()
            self.addChildSidePanelController(self.leftViewController!)
        }
    }
    
    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = UIStoryboard.rightViewController()
            
            rightViewController!.delegate = centerViewController
            view.insertSubview(rightViewController!.view, at: 0)
            addChildViewController(rightViewController!)
            rightViewController!.didMove(toParentViewController: self)
        }
    }
  
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        sidePanelController.delegate = centerViewController

        view.insertSubview(sidePanelController.view, at: 0)

        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
  
  func animateLeftPanel(shouldExpand: Bool) {
    if (shouldExpand) {
      currentState = .leftPanelExpanded
      
      animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
    }
    else {
        animateCenterPanelXPosition(targetPosition: 0) {
            finished in
            self.currentState = .bothCollapsed

            self.leftViewController!.view.removeFromSuperview()
            self.leftViewController = nil;
        }
    }
  }
  
  func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
      self.centerNavigationController.view.frame.origin.x = targetPosition
      }, completion: completion)
  }
  
  func animateRightPanel(shouldExpand: Bool) {
    if (shouldExpand) {
      currentState = .rightPanelExpanded
      
      animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width + centerPanelExpandedOffset)
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .bothCollapsed
        
        self.rightViewController!.view.removeFromSuperview()
        self.rightViewController = nil;
      }
    }
  }
  
  func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
    if (shouldShowShadow) {
      centerNavigationController.view.layer.shadowOpacity = 0.8
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
    }
  }
  
}

extension ContainerViewController: UIGestureRecognizerDelegate {
  // MARK: Gesture recognizer
  
  func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    
    if slidePanelsEnabled == false { return }
    
    let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
    
    switch(recognizer.state) {
    case .began:
      if (currentState == .bothCollapsed) {
        if (gestureIsDraggingFromLeftToRight) {
          addLeftPanelViewController()
        } else {
          addRightPanelViewController()
        }
        
        showShadowForCenterViewController(true)
      }
    case .changed:
      recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
      recognizer.setTranslation(CGPoint.zero, in: view)
    case .ended:
      if (leftViewController != nil) {
        // animate the side panel open or closed based on whether the view has moved more or less than halfway
        let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
        animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
      } else if (rightViewController != nil) {
        let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
        animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
      }
    default:
      break
    }
  }
}

private extension UIStoryboard {
  class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
  
  class func leftViewController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
  }
  
  class func rightViewController() -> RightPanelViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? RightPanelViewController
  }
  
  class func centerViewController() -> CenterViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "CenterViewController") as? CenterViewController
  }
  
}
