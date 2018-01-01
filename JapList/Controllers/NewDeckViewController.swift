//
//  NewDeckViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class NewDeckViewController: UIViewController {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextField: UITextView!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveUploadBtn: UIButton!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var defHeight : CGFloat? = 0
    var actInd = MyActInd()
    var upload : Bool? = false
    var keyboardOnScreen = false
    var deck : Deck? = nil
    let tapRec = UITapGestureRecognizer()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil
    var timeAdded : NSDate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        stack = delegate.stack
        firstDeckCheck()
        setup()
        configureAuth()

    }
    
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        // listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            // refresh table data
            //            self.decks.removeAll(keepingCapacity: false)
            //            self.onlineDecks.reloadData()
            
            // check if there is a current user
            performUIUpdatesOnMain {
                
            
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                self.saveUploadBtn.isHidden = false
            } else {
                // user must sign in
                self.saveUploadBtn.isHidden = true

                }
            }
        }
    }

    
    @objc func tappedImage(){
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func firstDeckCheck(){
        if isFirstDeck(){
            alert(title: "Hint", message: "Tap Image to choose a new one.", controller: self)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if deck == nil{
        dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        setUIEnabled(false)
        if (titleTextField.text?.isEmpty)! {
            alert(title: "Invalid Title", message: "Title cannot be empty", controller: self)
            setUIEnabled(true)
            return
        }
        let imageData = UIImageJPEGRepresentation(self.coverImage.image!, 0.8)!
        let name = self.titleTextField.text!
        let desc = self.descTextField.text!
        if deck != nil{
            updateLocalDeck(deck: self.deck!, title: name, desc: desc, cover: imageData, stack: self.stack!)
            
            
        } else {
            stack?.performBackgroundBatchOperation{
                (workingContext) in
            
                let newDeck = Deck(cover: imageData, title : name , desc : desc, context: workingContext)
                self.timeAdded = newDeck.createdDate
            }
        }
            
        setUIEnabled(true)
    }
    
    @IBAction func saveUploadImage(_ sender: Any) {
        upload = true
        setUIEnabled(false)
        if (titleTextField.text?.isEmpty)! {
            alert(title: "Invalid Title", message: "Title cannot be empty", controller: self)
            setUIEnabled(true)
            return
        }
        let imageData = UIImageJPEGRepresentation(self.coverImage.image!, 0.8)!
        let name = self.titleTextField.text!
        let desc = self.descTextField.text!
        if deck != nil{
            updateLocalDeck(deck: self.deck!, title: name, desc: desc, cover: imageData, stack: self.stack!)
            
            
        } else {
            stack?.performBackgroundBatchOperation{
                (workingContext) in
                
                let newDeck = Deck(cover: imageData, title : name , desc : desc, context: workingContext)
                self.timeAdded = newDeck.createdDate
            }
        }
        
        setUIEnabled(true)
    }
    

}

extension NewDeckViewController {
    
    func setUIEnabled(_ enabled : Bool){
        titleTextField.isEnabled = enabled
        descTextField.isEditable = enabled
        coverImage.isUserInteractionEnabled = enabled
        saveBtn.isEnabled = enabled
        if enabled {
            titleTextField.alpha = 1
            descTextField.alpha = 1
            coverImage.alpha = 1
            saveBtn.alpha = 1
            actInd.hide()

        } else {
            titleTextField.alpha = 0.5
            descTextField.alpha = 0.5
            coverImage.alpha = 0.5
            saveBtn.alpha = 0.5
            actInd.show(self.view)

        }
        
        
        
    }
    
    func setup(){
        if deck != nil{
            titleTextField.text = deck?.name
            descTextField.text = deck?.desc
            coverImage.image = UIImage(data: (deck?.cover)! as Data)
            navbar.topItem?.title = "Edit Deck"
            saveUploadBtn.isHidden = true
        }
        setUIEnabled(true)
        tapRec.addTarget(self, action: #selector(NewDeckViewController.tappedImage))
        coverImage.addGestureRecognizer(tapRec)
        
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context,  controller: self)
        
        subscribeToKeyboardNotifications()
        
        
    }
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow), controller: self)
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide), controller: self)
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow), controller: self)
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide), controller: self)
    }
    
    
    
}


extension NewDeckViewController {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            for insert in inserts {
                print("Inserts")
                print(inserts.count)
                if insert is Deck {
                    if let deck = (insert as? Deck), deck.createdDate == self.timeAdded{
                        print("We did it")
                        if self.upload!{
                            print("Uploaded")
                            FirebaseUtils.startUpdateUpload(defaultStore: delegate.defaultStore!, deck: deck, completionHandler: {(error) in
                                performUIUpdatesOnMain {
                                    if let err = error{
                                        print("hello")
                                        alert(title: "Error", message: err, controller: self)
                                    } else {
                                        print("hiyo")
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    }
                                }
                            })
                        }
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
                    if let deck = (update as? Deck){
                        if self.deck != nil{
                            if deck.objectID == (self.deck?.objectID)! {
                                if self.upload!{
                                    print("Uploaded Edit")
                                    FirebaseUtils.startUpdateUpload(defaultStore: delegate.defaultStore!, deck: deck, completionHandler: {(error) in
                                            performUIUpdatesOnMain {
                                                if let err = error{
                                                    alert(title: "Error", message: err, controller: self)
                                                } else {
                                                    print("herro no error")
                                                    self.navigationController?.popViewController(animated: true)

                                                }
                                            }
                                    })
                                } else {
                                performUIUpdatesOnMain {
                                    self.navigationController?.popViewController(animated: true)
                                    
                                }
                                }
                            }
                        }
                    }
                    
                }
            }
            
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
           
           
        }
    }
    
}

extension NewDeckViewController : UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("idk")
        // Try to find next responder
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }else if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextView {
            nextField.becomeFirstResponder()
        }else {
            // Not found, so remove keyboard.
        textField.resignFirstResponder()
        }
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if !keyboardOnScreen {
            self.defHeight = self.keyboardHeight(notification)
            self.view.frame.origin.y -= self.keyboardHeight(notification)
            if titleTextField.isFirstResponder {
                let h = self.view.frame.origin.y
                let h2 = titleTextField.frame.origin.y
                print(h)
                print(h2)
                if h2 - h < 50.0 {
                    self.view.frame.origin.y  += (50.0 - (h2 - h))
                    self.defHeight = self.defHeight! + CGFloat(50.0 - Float(h2 - h))
                }
                
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
//            self.view.frame.origin.y += self.keyboardHeight(notification)
            self.view.frame.origin.y += self.defHeight!
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
       
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        return ((notification as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
    }
    
    
}
extension NewDeckViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        // constant to hold the information about the photo
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let _ = UIImageJPEGRepresentation(photo, 0.8) {
            
            // call function to upload photo message
            coverImage.image = photo
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

