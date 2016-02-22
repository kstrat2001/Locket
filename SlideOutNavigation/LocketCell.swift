//
//  LocketCell.swift
//  Locket
//
//  Created by Kain Osterholt on 2/11/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

class LocketCell: UITableViewCell
{
    @IBOutlet weak var locketThumbnailView: DownloadableImageView!
    @IBOutlet weak var locketTitleLabel: UILabel!
    
    func configureForLocket(locket: Locket)
    {
        locketTitleLabel.text = locket.getTitle();
        
        locketThumbnailView.loadImageFromUrl(locket.getThumbUrl())
    }
}