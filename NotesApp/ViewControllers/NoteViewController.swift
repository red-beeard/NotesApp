//
//  NoteViewController.swift
//  NotesApp
//
//  Created by Red Beard on 30.09.2021.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mainTextView: UITextView!
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let note = note, let textNote = note.mainText {
            mainTextView.textColor = .black
            titleTextField.text = note.title
            if textNote.isEmpty {
                mainTextView.setupPlaceholder()
            } else {
                mainTextView.text = textNote
            }
        } else {
            mainTextView.setupPlaceholder()
        }
    }
    
}

//MARK: - Work with CoreData
extension NoteViewController {
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func saveNote(title: String, mainText: String) {
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return }
        
        let note = self.note ?? Note(entity: entity, insertInto: context)
        if self.note == nil {
            self.note = note
            note.id = UUID()
        }
        note.edited = Date.now
        note.title = title
        note.mainText = mainTextView.textIsPlaceholder() ? "" : mainText
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteNote() {
        let context = getContext()
        if let note = note {
            context.delete(note)
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - Handling text changes
extension NoteViewController: UITextFieldDelegate, UITextViewDelegate {
    @IBAction func titleTextFieldChanging(_ sender: Any) {
        textChanging()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanging()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textIsPlaceholder() {
            textView.deletePlaceholder()
        }
    }
    
    private func textChanging() {
        if let text = titleTextField.text, !(text.isEmpty) {
            saveNote(title: text, mainText: mainTextView.text)
        } else if !(mainTextView.text.isEmpty || mainTextView.textIsPlaceholder()) {
            saveNote(title: "New note", mainText: mainTextView.text)
        } else {
            deleteNote()
        }
    }
}

// MARK: - Work with keyboard
extension NoteViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mainTextView.becomeFirstResponder()
        return true
    }
}
