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
    
    private (set) var userLocket : UserLocketEntity?
    
    func configureForLocket(userLocket: UserLocketEntity)
    {
        self.userLocket = userLocket
        locketTitleLabel.text = userLocket.caption_text
        locketTitleLabel.textColor = userLocket.caption_color.uicolor
        locketTitleLabel.font = UIFont(name: userLocket.caption_font, size: gTableCellFontSize)
        locketThumbnailView.loadImageFromUrl(userLocket.locket_skin.closed_image.thumbURL)
        self.backgroundColor = userLocket.background_color.uicolor
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
    }
}