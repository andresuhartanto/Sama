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
        
        print(nameTextField.text!)
        
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
                print("Registration Completed!")
                
                // Stop Progress bar and navigate to Main screen
//                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToMainScreen", sender: self)
            }
        }
    }
    
    func displayAlert(_ message : String) {
        let alert = UIAlertController(title: "Oops something's wrong", message: "\(message)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
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
