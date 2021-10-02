//
//  ViewController.swift
//  NotesApp
//
//  Created by Red Beard on 30.09.2021.
//

import UIKit

class ListNotesViewController: UIViewController {
    
    private var notes: [Note] = CoreDataManager.shared.loadNotes()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults()
        if !defaults.bool(forKey: "wasFirstLaunch") {
            defaults.set(true, forKey: "wasFirstLaunch")
            firstRun()
        }
        
        if notes.count == 0 {
            tableView.isHidden = true
            noNotesLabel.isHidden = false
        } else {
            tableView.isHidden = false
            noNotesLabel.isHidden = true
        }
    }
    
    func firstRun() {
        let note = Note(
            id: UUID.init(),
            title: "First note",
            mainText: "Text of first note",
            edited: Date.now
        )

        do {
            try CoreDataManager.shared.saveNote(savedNote: note)
        } catch {
            debugPrint(error)
        }
        notes.append(note)
        
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
