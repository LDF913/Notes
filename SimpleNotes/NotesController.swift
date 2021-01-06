import UIKit
import RealmSwift

class NotesController: UITableViewController {
    
    var notes: List<Notes>!
    var folder: Folders!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = folder.title
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notes", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            let note = notes[indexPath.row]
                
            try! realm.write {
            realm.delete(note)
            }

            let indexPaths = [indexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
                
        try! realm.write {
            notes.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }

    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      return getfooterView()
  }

    func getfooterView() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Double(self.tableView.frame.size.width), height: 45))
        let button = UIButton()
         button.frame = CGRect(x: 0, y: 0, width: header.frame.size.width , height: header.frame.size.height)
        button.backgroundColor = .clear
        button.setTitle("Add Note", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)

        header.addSubview(button)
        header.bringSubviewToFront(button)
        return header
    }
    
    @objc func submitAction() {
        if notes.count > 5 && !UserDefaults.standard.bool(forKey: "Premium") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Premium")
            self.present(controller, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "AddNote", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddNote" {
    let controller = segue.destination as! NoteController
    controller.notes = notes
    } else if segue.identifier == "EditNote" {
        let controller = segue.destination as! NoteController
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            controller.editItem = notes[indexPath.row]
            controller.noteTitle = notes[indexPath.row].text
        }
    }
 }

}
