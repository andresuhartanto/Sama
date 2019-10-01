//
//  LoginViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 19/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
            
        if Auth.auth().currentUser != nil {
           self.performSegue(withIdentifier: "goToMainScreen", sender: nil)
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        // Start Progress animation
//        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print(error!)
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    var errorMessage = ""
                    
                    switch errorCode {
                        case .invalidEmail:
                            errorMessage = "Email is invalid"
                        case .userNotFound:
                            errorMessage = "User not found"
                        case .missingEmail:
                            errorMessage = "Please add your valid email address"
                        case .wrongPassword:
                            errorMessage = "Password is incorrect"
                        default:
                            print("Create User Error: \(error!)")
                    }
                    
                    self.displayAlert(errorMessage)
                    
                }
            } else {
                print("Login Successful")
                
                // Stop progress animation and navigate to main screen
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
