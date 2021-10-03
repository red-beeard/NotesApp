//
//  ViewController.swift
//  NotesApp
//
//  Created by Red Beard on 30.09.2021.
//

import UIKit
import CoreData

class ListNotesViewController: UIViewController {
    
    // Если всплывает ошибка с типом, то нужно удалить DerivedData
    // в /Users/red_beard/Library/Developer/Xcode и перезапустить Xcode
    private var notes: [Note] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotesLabel: UILabel!
    
    //MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        deleteAllNotes()
        
        let defaults = UserDefaults()
        if !defaults.bool(forKey: "wasFirstLaunch") {
            defaults.set(true, forKey: "wasFirstLaunch")
            saveNote(title: "First note", mainText: "Text of first note")
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
        needChangeVisibility()
    }
    
    private func needChangeVisibility() {
        if notes.count == 0 {
            tableView.isHidden = true
            noNotesLabel.isHidden = false
        } else {
            tableView.isHidden = false
            noNotesLabel.isHidden = true
        }
    }
}
    
//MARK: - Work with CoreData
extension ListNotesViewController {
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func saveNote(title: String, mainText: String) {
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else { return }
        
        let note = Note(entity: entity, insertInto: context)
        note.id = UUID()
        note.edited = Date.now
        note.title = title
        note.mainText = mainText
        
        do {
            try context.save()
            notes.insert(note, at: 0)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func loadNotes() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "edited", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            notes = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteNote(note: Note) {
        let context = getContext()
        context.delete(note)
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteAllNotes() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        if let notes = try? context.fetch(fetchRequest) {
            for note in notes {
                context.delete(note)
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Table view data source
extension ListNotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath)
        let note = notes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = note.title
        content.secondaryText = note.mainText
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let note = notes.remove(at: indexPath.row)
            deleteNote(note: note)
            needChangeVisibility()
            tableView.reloadData()
        }
    }
}

// MARK: - Navigate
extension ListNotesViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let noteVC = segue.destination as? NoteViewController else { return }
        
        if segue.identifier == "open" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            tableView.deselectRow(at: indexPath, animated: true)
            let note = notes[indexPath.row]
            noteVC.note = note
        } else if segue.identifier == "add new" {
            noteVC.note = nil
        }
    }
}
