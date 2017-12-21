//
//  NewDeckViewController.swift
//  JapList
//
//  Created by Dane Miller on 12/18/17.
//  Copyright © 2017 Dane Miller. All rights reserved.
//

import UIKit
import CoreData

class NewDeckViewController: UIViewController {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    let tapRec = UITapGestureRecognizer()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack : CoreDataStack? = nil
    var timeAdded : NSDate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        stack = delegate.stack
        

    }
    
    @objc func tappedImage(){
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: Any) {
        setUIEnabled(false)
        if (titleTextField.text?.isEmpty)! {
            alert(title: "Invalid Title", message: "Title cannot be empty", controller: self)
            return
        }
    
        let newDeck = Deck(cover: UIImageJPEGRepresentation(self.coverImage.image!, 0.8)!, title : self.titleTextField.text!, context: (stack?.context)!)
        self.timeAdded = newDeck.createdDate
        print(newDeck)
        stack?.save()
            
        setUIEnabled(true)
    }
    

}

extension NewDeckViewController {
    
    func setUIEnabled(_ enabled : Bool){
        titleTextField.isEnabled = enabled
        descTextField.isEnabled = enabled
        coverImage.isUserInteractionEnabled = enabled
        saveBtn.isEnabled = enabled
        if enabled {
            titleTextField.alpha = 1
            descTextField.alpha = 1
            coverImage.alpha = 1
            saveBtn.alpha = 1
        } else {
            titleTextField.alpha = 0.5
            descTextField.alpha = 0.5
            coverImage.alpha = 0.5
            saveBtn.alpha = 0.5
        }
        
        
        
    }
    
    func setup(){
        setUIEnabled(true)
        tapRec.addTarget(self, action: #selector(NewDeckViewController.tappedImage))
        coverImage.addGestureRecognizer(tapRec)
        
        
        subscribeToNotification(.NSManagedObjectContextObjectsDidChange, selector: #selector(managedObjectContextObjectsDidChange), controller: self)
        
        
    }
    
    
    
}


extension NewDeckViewController {
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        print("oopsy")
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            for insert in inserts {
                if insert is Deck {
                    if let deck = (insert as? Deck), deck.createdDate == self.timeAdded{
                        print("We did it")
                        performUIUpdatesOnMain {
                            self.dismiss(animated: true, completion: nil)

                        }
                    }
                    
                }
            }
                
                
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            
            print("[PhotoAlbum] Updated \(updates.count)")
            
            
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
           
           
        }
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

