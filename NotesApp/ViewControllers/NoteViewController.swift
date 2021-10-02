//
//  NoteViewController.swift
//  NotesApp
//
//  Created by Red Beard on 30.09.2021.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var mainTextView: UITextView!
    
    var note: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let note = note {
            titleTextView.text = note.title
            mainTextView.text = note.mainText
        }
    }
}
