//
//  UserLocketCell.swift
//  Locket
//
//  Created by Kain Osterholt on 2/21/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

class UserLocketCell: UITableViewCell
{
    @IBOutlet weak var locketThumbnailView: DownloadableImageView!
    @IBOutlet weak var locketTitleLabel: UILabel!
    
    fileprivate (set) var gradient: CAGradientLayer! = CAGradientLayer()
    fileprivate (set) var gradient2: CAGradientLayer! = CAGradientLayer()
    
    fileprivate (set) var userLocket : UserLocketEntity?
    
    func configureForLocket(_ userLocket: UserLocketEntity) {
        self.userLocket = userLocket
        locketTitleLabel.text = userLocket.caption_text
        locketTitleLabel.textColor = userLocket.caption_color.uicolor
        locketTitleLabel.font = UIFont(name: userLocket.caption_font, size: gTableCellFontSize)
        locketThumbnailView.loadImageFromUrl(userLocket.locket_skin.closed_image.thumbURL)
        self.backgroundColor = userLocket.background_color.uicolor
        
        gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradient.colors = [userLocket.background_color.inverse.cgColor, (self.backgroundColor?.cgColor)!]
        gradient.opacity = 0.0
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.2)
        gradient.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
        
        gradient2 = CAGradientLayer()
        gradient2.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradient2.colors = [userLocket.background_color.inverse.cgColor, (self.backgroundColor?.cgColor)!]
        gradient2.opacity = 0.0
        gradient2.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradient2.endPoint = CGPoint(x: 0.5, y: 0.8)
        gradient2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.insertSublayer(gradient2, at: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                if selected == true {
                    self.locketThumbnailView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.gradient.opacity = 0.5
                    self.gradient2.opacity = 0.5
                } else {
                    self.locketThumbnailView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.gradient.opacity = 0.0
                    self.gradient2.opacity = 0.0
                }
            },
            completion: { (value: Bool) in
        })
    }
}
