import UIKit
import RealmSwift

class FoldersController: UITableViewController {
    
    var folders: Results<Folders>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        folders = realm.objects(Folders.self).sorted(byKeyPath: "order")
        
        navigationItem.rightBarButtonItem = editButtonItem

    }
    
    @IBAction func addFolder(_ sender: UIBarButtonItem) {
        
        if folders.count > 3 && !UserDefaults.standard.bool(forKey: "Premium") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Premium")
            self.present(controller, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Add Folder", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.font = .systemFont(ofSize: 17)
            }
            
               let submit = UIAlertAction(title: "Add", style: .default) { [unowned alert] _ in
               let textField = alert.textFields![0]
                if textField.text != "" {
                    
                    let item = Folders()
                    item.title = textField.text!
                                                    
                    try! realm.write {
                        realm.add(item)
                    }
                    
                    let row = self.folders.count - 1
                    let indexPath = IndexPath(row: row, section: 0)
                    let indexPaths = [indexPath]
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alert.addAction(cancel)
            alert.addAction(submit)
            
            present(alert, animated: true)
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folders", for: indexPath)
        let folder = folders[indexPath.row]
        cell.textLabel?.text = folder.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            let folder = folders[indexPath.row]
                
            try! realm.write {
            realm.delete(folder)
            }

            let indexPaths = [indexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let sourceObject = folders[sourceIndexPath.row]
            let destinationObject = folders[destinationIndexPath.row]

            let destinationObjectOrder = destinationObject.order

            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = folders[index]
                    object.order -= 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let object = folders[index]
                    object.order += 1
                }
            }
            sourceObject.order = destinationObjectOrder
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let folder = folders[indexPath.row]

        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.text = folder.title
        }

           let submit = UIAlertAction(title: "Save", style: .default) { [unowned alert] _ in
            let newItem = alert.textFields![0]
            if newItem.text != "" {
                
                try! realm.write {
                    folder.title = newItem.text!
                }
                self.tableView.reloadData()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(cancel)
        alert.addAction(submit)

        present(alert, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let controller = segue.destination as! NotesController
    if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        controller.notes = folders[indexPath.row].notes
        controller.folder = folders[indexPath.row]
        }
    }
    
}
