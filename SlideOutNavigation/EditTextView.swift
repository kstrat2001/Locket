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
    func editTextViewTextChanged(_ text: String)
    func editTextViewFinishedEditing()
    func editTextViewFontChanged(_ font: String)
    func editTextViewColorChanged(_ color: UIColor)
}

class EditTextView : UIView, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    @IBOutlet weak var pickerDoneItem: UIBarButtonItem!
    
    fileprivate var colorEditView: EditColorView!
    
    var delegate : EditTextViewDelegate?
    var text : String = ""
    
    fileprivate var fontNames : [NSAttributedString]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        var numTotalFonts = 0;
        
        fontNames = Array<NSAttributedString>()
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            let names = UIFont.fontNames(forFamilyName: familyName)
            
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
        colorEditView.isHidden = true
    }
    
    func initEvents()
    {
        textField.alpha = 0.0
        let colorEditHeight = self.frame.height * 0.35
        colorEditView.frame = CGRect(x: 0, y: self.frame.height - colorEditHeight, width: self.frame.width, height: colorEditHeight)
        
        // Start the font picker below the screen
        let offset = self.pickerView.frame.height + self.pickerToolbar.frame.height
        let transform = CGAffineTransform(translationX: 0, y: offset)
        self.pickerView.transform = transform
        self.pickerToolbar.transform = transform
        
        self.insertSubview(colorEditView, belowSubview: self.pickerView)
        self.colorEditView.transform = CGAffineTransform(translationX: 0, y: self.colorEditView.frame.height)
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(EditTextView.textFieldChanged), for: UIControlEvents.editingChanged)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.pickerView.isHidden = false
        self.pickerToolbar.isHidden = false
        self.colorEditView.isHidden = false
    }
    
    func showKeyboard()
    {
        textField.becomeFirstResponder()
        
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.textField.alpha = 1.0
            },
            completion: { (value: Bool) in
        })
    }
    
    func setTextFieldText(_ text: String)
    {
        self.text = text
        self.textField.text = text
    }
    
    func textFieldChanged()
    {
        self.text = self.textField.text!
        delegate?.editTextViewTextChanged(self.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.transitionToFontEditing()
        return true
    }
    
    fileprivate func transitionToFontEditing()
    {
        textField.resignFirstResponder()
        self.pickerDoneItem.action = #selector(EditTextView.doneSelectingFont)
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.textField.alpha = 0.0
                let transform = CGAffineTransform(translationX: 0, y: 0)
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
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.pickerView.transform = CGAffineTransform(translationX: 0, y: self.pickerView.frame.height + self.pickerToolbar.frame.height)
                self.colorEditView.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: { (value: Bool) in
        })
    }
    
    func doneSelectingColor()
    {
        UIView.animate(withDuration: gEditAnimationDuration, delay: 0, usingSpringWithDamping: gEditAnimationDamping, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                let transform = CGAffineTransform(translationX: 0, y: self.pickerView.frame.height + self.pickerToolbar.frame.height)
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return fontNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.editTextViewFontChanged(fontNames[row].string)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let fontName = fontNames[row]
        let myAttribute = [ NSFontAttributeName: UIFont(name: fontName.string, size: 20.0)!]
        let attrStr = NSAttributedString(string: fontName.string, attributes: myAttribute)
        let labelView = UILabel()
        labelView.attributedText = attrStr
        labelView.textAlignment = NSTextAlignment.center
        
        return labelView
        
    }
}

extension EditTextView : EditColorViewDelegate
{
    func EditColorViewColorChanged(_ color: UIColor) {
        delegate?.editTextViewColorChanged(color)
    }
}
