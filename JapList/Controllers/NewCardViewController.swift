//
//  NewCardViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import CoreData

class NewCardViewController: UIViewController {

    var activeField : UITextField? = nil
    var deck : Deck? = nil
    var keyboardOnScreen = false
    @IBOutlet weak var kanjiTextField: UITextField!
    @IBOutlet weak var kanaTextField: UITextField!
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToKeyboardNotifications()
        stack = delegate.stack
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context,  controller: self)
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        print("save")
        if (kanjiTextField.text?.isEmpty)! && (kanaTextField.text?.isEmpty)! {
            alert(title: "Missing Japanese", message: "Please fill either the kana field or kanji field or both", controller: self)
            return
        }
        if (translationTextField.text?.isEmpty)! {
            alert(title: "Missing Translation", message: "わかりません.", controller: self)
            return
        }
        
        let kana = kanaTextField.text ?? ""
        let kanji = kanjiTextField.text ?? ""
        let trans = translationTextField.text
        newCard(deck :deck!, kanji: kanji,trans : trans, kana : kana, stack : stack!)

        dismiss(animated: true, completion: nil)
        
    }
    


}

extension NewCardViewController {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            for insert in inserts {
                print("Inserts")
                print(inserts.count)
                if insert is Card {
                    
                    if (insert as! Card).deck! == self.deck!{
                        performUIUpdatesOnMain {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                }
            }
            
            
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            
            for update in updates {
                if update is Deck {
                    
                    
                }
            }
            
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            
            
        }
    }
    
}


extension NewCardViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        activeField = nil
    }
    
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        print("Show")
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        print("Hide")
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if activeField == kanjiTextField{
            keyboardOnScreen = false
        } else {
            keyboardOnScreen = true
        }
        
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        return ((notification as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow), controller: self)
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide), controller: self)
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow), controller: self)
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide), controller: self)
    }
}
