import RealmSwift

let realm = try! Realm()

class Folders: Object {
    @objc dynamic var title = ""
    @objc dynamic var order = 0
    var notes = List<Notes>()
}

class Notes: Object {
    @objc dynamic var title = ""
    @objc dynamic var text = ""
}
