//
//  RegisterViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 20/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        // Start showing progress
//        SVProgressHUD.show()
        
        let name = self.nameTextField.text!
        if name != "" {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    print(error!)
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        var errorMessage = ""
                        
                        switch errorCode {
                            case .invalidEmail:
                                errorMessage = "Email is invalid"
                            case .emailAlreadyInUse:
                                errorMessage = "Email is already in use"
                            case .weakPassword:
                                errorMessage = "Password must be 6 characters long or more"
                            case .missingEmail:
                                errorMessage = "Please add your valid email address"
                            default:
                                print("Create User Error: \(error!)")
                        }
                        
                        self.displayAlert(errorMessage)
                        
                    }
                    
                } else {
                    self.saveUserData(name, self.emailTextField.text!)
                    self.performSegue(withIdentifier: "goToMainScreen", sender: self)
                    print("Registration Completed!")
                }
            }
        } else {
            self.displayAlert("Name could not be empty")
        }
    }
    
    func displayAlert(_ message : String) {
        let alert = UIAlertController(title: "Oops something's wrong", message: "\(message)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // Save user data to Firebase
    func saveUserData(_ name: String, _ email : String) {
        let userDB = Database.database().reference().child("Users")
        guard let uid = Auth.auth().currentUser?.uid else {
            fatalError("Could not get user UID")
        }
        print(uid)
        let userDataDictionary = ["name": "\(name)", "email": "\(email)"]
        
        let data = [uid: userDataDictionary]
        
        userDB.setValue(data) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
        
    }
    
    @objc func viewTapped() {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        nameTextField.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
