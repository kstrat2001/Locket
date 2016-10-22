//
//  LocketCell.swift
//  Locket
//
//  Created by Kain Osterholt on 2/11/16.
//  Copyright © 2016 Kain Osterholt. All rights reserved.
//

import Foundation
import UIKit

class LocketCell: UITableViewCell
{
    @IBOutlet weak var locketThumbnailView: DownloadableImageView!
    @IBOutlet weak var locketTitleLabel: UILabel!
    
    func configureForLocket(_ locket: LocketSkinEntity)
    {
        locketTitleLabel.text = locket.title;
        
        locketThumbnailView.loadImageFromUrl(locket.closed_image.thumbURL)
        self.backgroundColor = gLightPinkColor
    }
}
