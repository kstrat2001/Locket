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
    @objc optional func toggleLeftPanel()
    @objc optional func toggleRightPanel()
    @objc optional func collapseSidePanels()
    @objc optional func enableSlidePanels(_ enable: Bool)
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
    func userLocketSelected(_ locket: UserLocketEntity) {
        locketView?.setUserLocket(locket)
    }
}

extension CenterViewController: SidePanelViewControllerDelegate
{
    func locketSkinSelected(_ skin: LocketSkinEntity)
    {
        let userLocket = SettingsManager.sharedManager.selectedLocket
        userLocket.locket_skin = skin
        DataManager.sharedManager.saveAllRecords()
        
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
        photoPicker.sourceType = .photoLibrary
        present(photoPicker, animated: true, completion: nil)
    }
    
    func takePhoto() {
        photoTaker.delegate = self
        photoTaker.allowsEditing = true
        photoTaker.sourceType = .camera
        present(photoTaker, animated: true, completion: nil)
    }
}

extension CenterViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        locketView?.setPhoto(image)
       dismiss(animated: true, completion: nil)
    }
}
