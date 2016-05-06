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
    
    private (set) var gradient: CAGradientLayer! = CAGradientLayer()
    private (set) var gradient2: CAGradientLayer! = CAGradientLayer()
    
    private (set) var userLocket : UserLocketEntity?
    
    func configureForLocket(userLocket: UserLocketEntity) {
        self.userLocket = userLocket
        locketTitleLabel.text = userLocket.caption_text
        locketTitleLabel.textColor = userLocket.caption_color.uicolor
        locketTitleLabel.font = UIFont(name: userLocket.caption_font, size: gTableCellFontSize)
        locketThumbnailView.loadImageFromUrl(userLocket.locket_skin.closed_image.thumbURL)
        self.backgroundColor = userLocket.background_color.uicolor
        
        gradient = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        gradient.colors = [userLocket.background_color.inverse.CGColor, (self.backgroundColor?.CGColor)!]
        gradient.opacity = 0.0
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.2)
        gradient.anchorPoint = CGPointMake(0.5, 0.5)
        self.layer.insertSublayer(gradient, atIndex: 0)
        
        gradient2 = CAGradientLayer()
        gradient2.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        gradient2.colors = [userLocket.background_color.inverse.CGColor, (self.backgroundColor?.CGColor)!]
        gradient2.opacity = 0.0
        gradient2.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradient2.endPoint = CGPoint(x: 0.5, y: 0.8)
        gradient2.anchorPoint = CGPointMake(0.5, 0.5)
        self.layer.insertSublayer(gradient2, atIndex: 0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                if selected == true {
                    self.locketThumbnailView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    self.gradient.opacity = 0.5
                    self.gradient2.opacity = 0.5
                } else {
                    self.locketThumbnailView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    self.gradient.opacity = 0.0
                    self.gradient2.opacity = 0.0
                }
            },
            completion: { (value: Bool) in
        })
    }
}