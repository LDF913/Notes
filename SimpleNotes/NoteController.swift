import UIKit
import RealmSwift

class NoteController: UIViewController, UITextViewDelegate {
    
    var notes: List<Notes>!
    var note: Notes!
    var noteTitle = ""
    var editItem: Notes?

    let headerAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
    let bodyAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.becomeFirstResponder()

        if let editItem = editItem {
            title = noteTitle
            textView.text = editItem.text
        } else {
            note = Notes()
            try! realm.write {
                notes.append(note)
            }
        }
        
        highlightFirstLineInTextView(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if let editItem = editItem {
            try! realm.write {
                editItem.text = textView.text!
            }
        } else {
            try! realm.write {
                note.text = textView.text!
            }
        }
    }
    
    func highlightFirstLineInTextView(_ textView: UITextView) {
        let textAsNSString = textView.text as NSString
        let lineBreakRange = textAsNSString.range(of: "\n")
        let newAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        let boldRange: NSRange
        if lineBreakRange.location < textAsNSString.length {
            boldRange = NSRange(location: 0, length: lineBreakRange.location)
        } else {
            boldRange = NSRange(location: 0, length: textAsNSString.length)
        }
        
        newAttributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline), range: boldRange)
        textView.attributedText = newAttributedText
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textAsNSString = self.textView.text as NSString
        let replaced = textAsNSString.replacingCharacters(in: range, with: text) as NSString
        let boldRange = replaced.range(of: "\n")
        if boldRange.location <= range.location {
            self.textView.typingAttributes = self.headerAttributes
        } else {
            self.textView.typingAttributes = self.bodyAttributes
        }
        
        return true
    }
    
    @IBAction func shareNote(_ sender: UIBarButtonItem) {
        let text = [textView.text]
        let activityViewController = UIActivityViewController(activityItems: text as [Any], applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
