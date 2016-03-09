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
    optional func enableSlidePanels(enable: Bool)
}

class CenterViewController: UIViewController, UINavigationControllerDelegate
{
    var delegate: CenterViewControllerDelegate?
    
    var locketView: LocketView?
    
    let photoPicker: UIImagePickerController = UIImagePickerController()
    let photoTaker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locketView = LocketView(frame: (self.view?.frame)!)
        locketView?.setUserLocket(SettingsManager.sharedManager.selectedLocket)
        locketView?.delegate = self
        
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

extension CenterViewController: LocketViewDelegate
{
    func locketViewDidFinishEditing() {
        delegate?.enableSlidePanels?(true)
    }
    
    func locketViewDidStartEditing() {
        delegate?.enableSlidePanels?(false)
    }
    
    func selectPhoto() {
        photoPicker.delegate = self
        photoPicker.allowsEditing = false
        photoPicker.sourceType = .PhotoLibrary
        presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    func takePhoto() {
        photoTaker.delegate = self
        photoTaker.allowsEditing = true
        photoTaker.sourceType = .Camera
        presentViewController(photoTaker, animated: true, completion: nil)
    }
}

extension CenterViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        locketView?.setPhoto(image)
       dismissViewControllerAnimated(true, completion: nil)
    }
}