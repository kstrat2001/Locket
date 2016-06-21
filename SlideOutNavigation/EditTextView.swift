//
//  EditTextView.swift
//  Locket
//
//  Created by Kain Osterholt on 3/8/16.
//  Copyright © 2016 James Frost. All rights reserved.
//

import Foundation
import UIKit

protocol EditTextViewDelegate
{
    func editTextViewTextChanged(text: String)
    func editTextViewFinishedEditing()
    func editTextViewFontChanged(font: String)
    func editTextViewColorChanged(color: UIColor)
}

class EditTextView : UIView, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    @IBOutlet weak var pickerDoneItem: UIBarButtonItem!
    
    private var colorEditView: EditColorView!
    
    var delegate : EditTextViewDelegate?
    var text : String = ""
    
    private var fontNames : [NSAttributedString]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        var numTotalFonts = 0;
        
        fontNames = Array<NSAttributedString>()
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            let names = UIFont.fontNamesForFamilyName(familyName)
            
            var indexInFamily = 0
            
            for name in names {
                let attrStr = NSAttributedString(string: name)
                fontNames.append(attrStr)
                numTotalFonts += 1
                
                // limit the number of fonts. currently only 1 per family
                if indexInFamily == 0 {
                    break;
                }
                
                indexInFamily += 1
            }
        }
        
        print("Total fonts loaded: \(numTotalFonts)")
        
        colorEditView = EditColorView.loadFromNibNamed("EditColorView") as! EditColorView

        colorEditView.delegate = self
        colorEditView.initEvents()
        colorEditView.hidden = true
    }
    
    func initEvents()
    {
        textField.alpha = 0.0
        let colorEditHeight = self.frame.height * 0.35
        colorEditView.frame = CGRect(x: 0, y: self.frame.height - colorEditHeight, width: self.frame.width, height: colorEditHeight)
        
        // Start the font picker below the screen
        let offset = self.pickerView.frame.height + self.pickerToolbar.frame.height
        let transform = CGAffineTransformMakeTranslation(0, offset)
        self.pickerView.transform = transform
        self.pickerToolbar.transform = transform
        
        self.insertSubview(colorEditView, belowSubview: self.pickerView)
        self.colorEditView.transform = CGAffineTransformMakeTranslation(0, self.colorEditView.frame.height)
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(EditTextView.textFieldChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.pickerView.hidden = false
        self.pickerToolbar.hidden = false
        self.colorEditView.hidden = false
    }
    
    func showKeyboard()
    {
        textField.becomeFirstResponder()
        
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.textField.alpha = 1.0
            },
            completion: { (value: Bool) in
        })
    }
    
    func setTextFieldText(text: String)
    {
        self.text = text
        self.textField.text = text
    }
    
    func textFieldChanged()
    {
        self.text = self.textField.text!
        delegate?.editTextViewTextChanged(self.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.transitionToFontEditing()
        return true
    }
    
    private func transitionToFontEditing()
    {
        textField.resignFirstResponder()
        self.pickerDoneItem.action = #selector(EditTextView.doneSelectingFont)
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.textField.alpha = 0.0
                let transform = CGAffineTransformMakeTranslation(0, 0)
                self.pickerView.transform = transform
                self.pickerToolbar.transform = transform

            },
            completion: { (value: Bool) in
        })
    }
    
    func doneSelectingFont()
    {
        self.transitionToColorEditing()
    }
    
    func transitionToColorEditing()
    {
        self.pickerDoneItem.action = #selector(EditTextView.doneSelectingColor)
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.pickerView.transform = CGAffineTransformMakeTranslation(0, self.pickerView.frame.height + self.pickerToolbar.frame.height)
                self.colorEditView.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { (value: Bool) in
        })
    }
    
    func doneSelectingColor()
    {
        UIView.animateWithDuration(gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                let transform = CGAffineTransformMakeTranslation(0, self.pickerView.frame.height + self.pickerToolbar.frame.height)
                self.colorEditView.transform = transform
                self.pickerToolbar.transform = transform
            },
            completion: { (value: Bool) in
        })
        
        self.delegate?.editTextViewFinishedEditing()
    }
}

extension EditTextView : UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNames.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return fontNames[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.editTextViewFontChanged(fontNames[row].string)
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let fontName = fontNames[row]
        let myAttribute = [ NSFontAttributeName: UIFont(name: fontName.string, size: 20.0)!]
        let attrStr = NSAttributedString(string: fontName.string, attributes: myAttribute)
        let labelView = UILabel()
        labelView.attributedText = attrStr
        labelView.textAlignment = NSTextAlignment.Center
        
        return labelView
        
    }
}

extension EditTextView : EditColorViewDelegate
{
    func EditColorViewColorChanged(color: UIColor) {
        delegate?.editTextViewColorChanged(color)
    }
}