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

        fontNames = Array<NSAttributedString>()
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            let names = UIFont.fontNamesForFamilyName(familyName)
            
            for name in names {
                fontNames.append(NSAttributedString(string: name))
            }
        }
        
        colorEditView = EditColorView.loadFromNibNamed("EditColorView") as! EditColorView

        colorEditView.delegate = self
        colorEditView.initEvents()
        colorEditView.hidden = true
        self.addSubview(colorEditView)
    }
    
    func initEvents()
    {
        let screenHeight = UIScreen.mainScreen().bounds.height
        colorEditView.frame = CGRect(x: 0, y: screenHeight - 152, width: self.frame.width, height: 152)
        
        textField.delegate = self
        textField.addTarget(self, action: "textFieldChanged", forControlEvents: UIControlEvents.EditingChanged)
        
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func showKeyboard()
    {
        textField.becomeFirstResponder()
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
        textField.resignFirstResponder()
        self.transitionToFontEditing()
        
        return true
    }
    
    private func transitionToFontEditing()
    {
        self.pickerDoneItem.action = "doneSelectingFont"
        self.textField.hidden = true
        self.pickerView.hidden = false
        self.pickerToolbar.hidden = false
    }
    
    func doneSelectingFont()
    {
        self.pickerView.hidden = true
        self.transitionToColorEditing()
    }
    
    func transitionToColorEditing()
    {
        self.pickerDoneItem.action = "doneSelectingColor"
        colorEditView.hidden = false
    }
    
    func doneSelectingColor()
    {
        self.pickerToolbar.hidden = true
        colorEditView.hidden = true
        self.textField.hidden = false

        delegate?.editTextViewFinishedEditing()
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
}

extension EditTextView : EditColorViewDelegate
{
    func EditColorViewColorChanged(color: UIColor) {
        delegate?.editTextViewColorChanged(color)
    }
}