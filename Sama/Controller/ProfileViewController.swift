//
//  ProfileViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 25/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var userUID: String = ""
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        userUID = getuserID()
        
        setUserInfo()
        prepareProfileImageView()
    }
    
    @IBAction func logoutBtnPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    private func setUserInfo() {
        let userRef = Database.database().reference().child("Users").child(userUID)
        userRef.observe(.value) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            
            let name = snapshotValue["name"] as! String
            self.nameLabel.text = name
            
            let profilePicture = snapshotValue["profilePicture"] as! Dictionary<String, String>
            let imageURL = profilePicture["url"] as! String
        }
    }
    
    private func prepareProfileImageView() {
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor(red: 95/255, green: 147/255, blue: 244/255, alpha: 1).cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        addTapGesture(profileImageView)
    }
    
    private func addTapGesture(_ imageView : UIImageView) {
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
    }
    
    @objc func imageTapped() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            fatalError("error getting image from profileImageView")
        }
        let imageName = userUID
        
        let imageRef = Storage.storage().reference().child("profile-picture").child(imageName + ".jpeg")
        
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading profile image! \(error)")
                return
            }
            
            imageRef.downloadURL { (url, err) in
                if let err = err {
                    fatalError("Error getting profile image URL! \(err)")
                }
                
                guard let imageURL = url else {
                    fatalError("Error getting image URL!")
                }
                
                let userRef = Database.database().reference().child("Users").child(self.userUID).child("profilePicture")
                
                let imageData = ["url" : imageURL.absoluteString]
                
                userRef.setValue(imageData)
                
            }
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.contentMode = .scaleToFill
            profileImageView.image = pickedImage
            
            uploadImage(pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
