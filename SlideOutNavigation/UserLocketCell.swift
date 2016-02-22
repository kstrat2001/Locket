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
    
    func configureForLocket(userLocket: UserLocket)
    {
        locketTitleLabel.text = userLocket.title
        
        locketThumbnailView.loadImageFromUrl(userLocket.locket.getThumbUrl())
    }
}