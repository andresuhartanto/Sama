//
//  CustomHeader.swift
//  Sama
//
//  Created by Andre Suhartanto on 24/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase

class CustomHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var pocketBtn: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var firstUserNameLabel: UILabel!
    @IBOutlet weak var secondUserNameLabel: UILabel!

    
    
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
    

}
