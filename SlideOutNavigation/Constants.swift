//
//  Constants.swift
//  Locket
//
//  Created by Kain Osterholt on 3/8/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

let gBGEditViewHeight = CGFloat(160.0)

let gTableCellFontSize = CGFloat(20.0)
let gTableCellFont = UIFont(name: "Optima", size: gTableCellFontSize)
let gLightPinkColor = UIColor(red: 1.0, green: 232.0/255.0, blue: 243.0/255.0, alpha: 1.0)

let gCaptionFontSize = CGFloat(40.0)
let gCaptionCenterYMultiplier = CGFloat(0.85)

let gEditAnimationDuration = NSTimeInterval(0.7)
let gEditAnimationDamping = CGFloat(0.9)

let gMaxCryptoBufferLength = 1024 * 50

let gDefaultImageAssetData : NSDictionary = [
    "title" : "default",
    "anchor_x" : 621,
    "anchor_y" : 0,
    "width" : 1242,
    "height" : 932,
    "image_full" : "http://mainbundle.app/default_image.png",
    "image_thumb" : "http://mainbundle.app/default_image.png"
]

let gDefaultLocketData : NSDictionary = [
    "title" : "default",
    "open_image" : [
        "title" : "default_open",
        "anchor_x" : 678,
        "anchor_y" : 35,
        "width" : 1187,
        "height" : 994,
        "image_full" : "http://mainbundle.app/default_open.png",
        "image_thumb" : "http://mainbundle.app/default_open.png"
    ],
    "closed_image" :[
        "title" : "default_closed",
        "anchor_x" : 492,
        "anchor_y" : 36,
        "width" : 1017,
        "height" : 994,
        "image_full" : "http://mainbundle.app/default_closed.png",
        "image_thumb" : "http://mainbundle.app/default_closed.png"
    ],
    "chain_image" :[
        "title" : "default_chain",
        "anchor_x" : 254,
        "anchor_y" : 760,
        "width" : 515,
        "height" : 770,
        "image_full" : "http://mainbundle.app/default_chain.png",
        "image_thumb" : "http://mainbundle.app/default_chain.png"
    ],
    "mask_image" :[
        "title" : "default_mask",
        "anchor_x" : 459,
        "anchor_y" : -35,
        "width" : 919,
        "height" : 814,
        "image_full" : "http://mainbundle.app/default_mask.png",
        "image_thumb" : "http://mainbundle.app/default_mask.png"
    ]
]

let gDefaultUserLocketData = [
    "title" : "default",
    "locket" : gDefaultLocketData,
    "image" : gDefaultImageAssetData,
    "caption_text" : "To cherish forever",
    "caption_font" : "Optima",
    "bg_color" : [ "red" : 0.80,
        "green" : 0.65,
        "blue" : 1.0,
        "alpha" : 1.0 ],
    "caption_color" : [ "red" : 0.0,
        "green" : 0.0,
        "blue" : 0.0,
        "alpha" : 1.0 ],
]
