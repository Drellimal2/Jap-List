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
    
    let tapRec = UITapGestureRecognizer()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let ActInd = MyActInd()
    let uploadingInd = MyActInd("Uploading")
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var defHeight : CGFloat? = 0
    var actInd = MyActInd()
    var upload : Bool? = false
    var keyboardOnScreen = false
    var deck : Deck? = nil
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
        
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            performUIUpdatesOnMain {
            
                if user != nil {
                    self.saveUploadBtn.isHidden = false
                } else {
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
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveImage(_ sender: Any) {
        upload = false
        setUIEnabled(false)
        actInd.show(self.view)
        if (titleTextField.text?.isEmpty)! {
            alert(title: "Invalid Title", message: "Title cannot be empty", controller: self)
            setUIEnabled(true)
            return
        }
        if !hasChanges(){
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            alert(title: "No changes detected", message: "There were no changes to the deck so we will exit.", controller: self, actions: [okAction])
            setUIEnabled(true)
            actInd.hide()
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
        
        print("Tap")
        upload = true
        setUIEnabled(false)
        if (titleTextField.text?.isEmpty)! {
            alert(title: "Invalid Title", message: "Title cannot be empty", controller: self)
            setUIEnabled(true)
            return
        }
        if !hasChanges(){
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.uploadToFirebase(deck: self.deck!)
            })
            alert(title: "No local changes detected", message: "There were no local changes to the deck and so it will just be uploaded.", controller: self, actions: [okAction])
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
    
    func uploadToFirebase(deck : Deck){
        performUIUpdatesOnMain {
            self.uploadingInd.show(self.view)

        }
        FirebaseUtils.startUpdateUpload(defaultStore: delegate.defaultStore!, deck: deck, completionHandler: { (error) in
            performUIUpdatesOnMain {
                self.uploadingInd.hide()

                if error != nil{
                    alert(title: "Uploading Error", message: "There was an error while uploading please try again", controller: self)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
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
        setupUI()
        self.saveUploadBtn.isHidden = true
        setUIEnabled(true)
        tapRec.addTarget(self, action: #selector(NewDeckViewController.tappedImage))
        coverImage.addGestureRecognizer(tapRec)
        
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), object: stack?.context,  controller: self)
        
        subscribeToKeyboardNotifications()
        
        
    }
    
    func setupUI(){
        if deck != nil{
            titleTextField.text = deck?.name
            descTextField.text = deck?.desc
            navbar.topItem?.title = "Edit Deck"
        }
    }
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow), controller: self)
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide), controller: self)
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow), controller: self)
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide), controller: self)
    }
    
    func hasChanges()->Bool{
        if self.deck == nil {
            return true
        }
        let titleCheck = self.deck?.name! != self.titleTextField.text!
        print(titleCheck)
        print(self.titleTextField.text!)
        let descCheck = self.deck?.desc! != descTextField.text!
        print(descCheck)
        print(titleCheck || descCheck)
        return titleCheck || descCheck
    }
    
    
    
}


extension NewDeckViewController {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            for insert in inserts {
                if insert is Deck {
                    if let deck = (insert as? Deck), deck.createdDate == self.timeAdded{
                        self.deck = deck
                        performUIUpdatesOnMain {
                            self.actInd.hide()
                        }
                        if self.upload!{
                            
                            if ReachabilityTest.isConnectedToNetwork(){
                                self.uploadToFirebase(deck: deck)
                            } else {
                                performUIUpdatesOnMain {
                                    alert(title: "Error uploading", message: "There seems to be some connection issues. Please check your connection and try again later.", controller: self)
                                }
                            }
                            
                            
                        } else {
                            performUIUpdatesOnMain {
                                self.dismiss(animated: true, completion: nil)
                            }
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
                                    
                                    if ReachabilityTest.isConnectedToNetwork(){
                                        self.uploadToFirebase(deck: deck)
                                    } else {
                                        performUIUpdatesOnMain {
                                            alert(title: "Error uploading", message: "There seems to be some internet issues. Please check your connection and try again later.", controller: self)
                                        }
                                    }
                                } else {
                                    performUIUpdatesOnMain {
                                        self.dismiss(animated: true, completion: nil)
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
        
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextView {
            nextField.becomeFirstResponder()
        } else {
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
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage, let _ = UIImageJPEGRepresentation(photo, 0.8) {
            coverImage.image = photo
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

