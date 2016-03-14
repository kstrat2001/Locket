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
    
    func configureForLocket(userLocket: UserLocketEntity)
    {
        locketTitleLabel.text = userLocket.caption_text
        locketTitleLabel.textColor = userLocket.caption_color.uicolor
        locketTitleLabel.font = UIFont(name: userLocket.caption_font, size: gTableCellFontSize)
        locketThumbnailView.loadImageFromUrl(userLocket.locket_skin.closed_image.thumbURL)
        self.backgroundColor = userLocket.background_color.uicolor
    }
}