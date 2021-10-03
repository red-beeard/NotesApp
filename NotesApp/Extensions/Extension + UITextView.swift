//
//  Extension + UITextView.swift
//  NotesApp
//
//  Created by Red Beard on 03.10.2021.
//

import UIKit

extension UITextView {
    func textIsPlaceholder() -> Bool {
        guard let textColor = self.textColor else { return true }
        return textColor == UIColor.lightGray && self.text == "Enter text"
    }
    
    func setupPlaceholder() {
        self.textColor = .lightGray
        self.text = "Enter text"
    }
    
    func deletePlaceholder() {
        self.text = ""
        self.textColor = .black
    }
}
