//
//  LoginViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 19/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToRegister", sender: self)
        print("Register pressed")
    }
    
    
}
