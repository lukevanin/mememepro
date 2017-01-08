//
//  MemeTextFieldDelegate.swift
//  MemeMe
//
//  Created by Luke Van In on 2017/01/05.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  UITextField delegate used in MemeViewController to manage editable text fields. 
//  Ensures default text is displayed if textfield is empty when editing completes.
//

import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    typealias EditingHandler = (UITextField) -> Void
    
    var onEditing : EditingHandler?
    
    // Default text to display in text field.
    private let defaultText : String
    
    init(defaultText: String) {
        self.defaultText = defaultText
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Remove default text if present.
        if textField.text == defaultText {
            textField.text = nil
        }
        
        // Notify the completion handler that the editing state has changed.
        onEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Display default text if textfield is empty.
        if textField.text?.isEmpty ?? true {
            textField.text = defaultText
        }
        
        // Notify the completion handler that the editing state has changed.
        onEditing?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
