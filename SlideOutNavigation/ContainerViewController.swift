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
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}

class ContainerViewController: UIViewController
{
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!

    var currentState: SlideOutState = .BothCollapsed
    {
        didSet
        {
          let shouldShowShadow = currentState != .BothCollapsed
          showShadowForCenterViewController(shouldShowShadow)
        }
    }

    var leftViewController: SidePanelViewController?
    var rightViewController: RightPanelViewController?

    let centerPanelExpandedOffset: CGFloat = 60
    
    // For enabling and disabling the sliding menus
    private (set) var slidePanelsEnabled: Bool = true

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

        centerNavigationController.didMoveToParentViewController(self)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        centerNavigationController.navigationBarHidden = true
    }
  
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate
{
    func enableSlidePanels(enable: Bool) {
        self.slidePanelsEnabled = enable
    }
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
    
        if notAlreadyExpanded
        {
            addLeftPanelViewController()
        }
    
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
  
    func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .RightPanelExpanded)
    
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
    
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
  
    func collapseSidePanels() {
        switch (currentState)
        {
            case .RightPanelExpanded:
              toggleRightPanel()
            case .LeftPanelExpanded:
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
            view.insertSubview(rightViewController!.view, atIndex: 0)
            addChildViewController(rightViewController!)
            rightViewController!.didMoveToParentViewController(self)
        }
    }
  
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        sidePanelController.delegate = centerViewController

        view.insertSubview(sidePanelController.view, atIndex: 0)

        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
  
  func animateLeftPanel(shouldExpand shouldExpand: Bool) {
    if (shouldExpand) {
      currentState = .LeftPanelExpanded
      
      animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
    }
    else {
        animateCenterPanelXPosition(targetPosition: 0) {
            finished in
            self.currentState = .BothCollapsed

            self.leftViewController!.view.removeFromSuperview()
            self.leftViewController = nil;
        }
    }
  }
  
  func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
      self.centerNavigationController.view.frame.origin.x = targetPosition
      }, completion: completion)
  }
  
  func animateRightPanel(shouldExpand shouldExpand: Bool) {
    if (shouldExpand) {
      currentState = .RightPanelExpanded
      
      animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerNavigationController.view.frame) + centerPanelExpandedOffset)
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .BothCollapsed
        
        self.rightViewController!.view.removeFromSuperview()
        self.rightViewController = nil;
      }
    }
  }
  
  func showShadowForCenterViewController(shouldShowShadow: Bool) {
    if (shouldShowShadow) {
      centerNavigationController.view.layer.shadowOpacity = 0.8
    } else {
      centerNavigationController.view.layer.shadowOpacity = 0.0
    }
  }
  
}

extension ContainerViewController: UIGestureRecognizerDelegate {
  // MARK: Gesture recognizer
  
  func handlePanGesture(recognizer: UIPanGestureRecognizer) {
    
    if slidePanelsEnabled == false { return }
    
    let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
    
    switch(recognizer.state) {
    case .Began:
      if (currentState == .BothCollapsed) {
        if (gestureIsDraggingFromLeftToRight) {
          addLeftPanelViewController()
        } else {
          addRightPanelViewController()
        }
        
        showShadowForCenterViewController(true)
      }
    case .Changed:
      recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
      recognizer.setTranslation(CGPointZero, inView: view)
    case .Ended:
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
  class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
  
  class func leftViewController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
  }
  
  class func rightViewController() -> RightPanelViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? RightPanelViewController
  }
  
  class func centerViewController() -> CenterViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
  }
  
}