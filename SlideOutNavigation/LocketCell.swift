//
//  LocketCell.swift
//  Locket
//
//  Created by Kain Osterholt on 2/11/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class LocketCell: UITableViewCell
{
    @IBOutlet weak var locketThumbnailView: UIImageView!
    @IBOutlet weak var locketTitleLabel: UILabel!
    
    func configureForLocket(locket: Locket)
    {
        locketTitleLabel.text = locket.getTitle();
        
        locketThumbnailView.af_setImageWithURL(locket.getThumbUrl())
    }
}