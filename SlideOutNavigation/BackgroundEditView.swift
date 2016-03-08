//
//  BackgroundEditView.swift
//  Locket
//
//  Created by Kain Osterholt on 2/29/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

protocol BGEditViewDelegate
{
    func BGEditViewColorChanged(color: UIColor)
}

class BackgroundEditView : UIView {
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    private (set) var red : Float! = 1.0
    private (set) var green : Float! = 1.0
    private (set) var blue : Float! = 1.0
    
    var delegate : BGEditViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setColor(red: Float, green: Float, blue: Float)
    {
        self.red = red
        self.green = green
        self.blue = blue
        
        redSlider.value = red
        greenSlider.value = green
        blueSlider.value = blue
    }
    
    func setColor(color: UIColor)
    {
        let col = color.coreImageColor
        
        self.setColor(Float((col?.red)!), green: Float((col?.green)!), blue: Float((col?.blue)!))
    }
    
    func initEvents()
    {
        self.redSlider.addTarget(self, action: "colorChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.greenSlider.addTarget(self, action: "colorChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.blueSlider.addTarget(self, action: "colorChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func colorChanged(slider: UISlider)
    {
        red = redSlider.value
        green = greenSlider.value
        blue = blueSlider.value
        
        delegate?.BGEditViewColorChanged(UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1.0))
    }
}