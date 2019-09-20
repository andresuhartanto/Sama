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
        overrideUserInterfaceStyle = .light
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        // Start Progress animation
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("Login Successful")
                
                // Stop progress animation and navigate to main screen
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToMainScreen", sender: self)
            }
        }
        
    }
    
    
}
