//
//  BackgroundEditView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/29/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

protocol EditColorViewDelegate
{
    func EditColorViewColorChanged(_ color: UIColor)
}

class EditColorView : UIView {
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    fileprivate (set) var red : Float! = 1.0
    fileprivate (set) var green : Float! = 1.0
    fileprivate (set) var blue : Float! = 1.0
    
    var delegate : EditColorViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setColor(_ red: Float, green: Float, blue: Float)
    {
        self.red = red
        self.green = green
        self.blue = blue
        
        redSlider.value = red
        greenSlider.value = green
        blueSlider.value = blue
    }
    
    func setColor(_ color: UIColor)
    {
        let col = color.coreImageColor
        
        self.setColor(Float((col?.red)!), green: Float((col?.green)!), blue: Float((col?.blue)!))
    }
    
    func initEvents()
    {
        self.redSlider.addTarget(self, action: #selector(EditColorView.colorChanged(_:)), for: UIControlEvents.valueChanged)
        self.greenSlider.addTarget(self, action: #selector(EditColorView.colorChanged(_:)), for: UIControlEvents.valueChanged)
        self.blueSlider.addTarget(self, action: #selector(EditColorView.colorChanged(_:)), for: UIControlEvents.valueChanged)
    }
    
    func colorChanged(_ slider: UISlider)
    {
        red = redSlider.value
        green = greenSlider.value
        blue = blueSlider.value
        
        delegate?.EditColorViewColorChanged(UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1.0))
    }
}
