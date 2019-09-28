//
//  AddNewPocketViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 27/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase

class AddNewPocketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pocketTableView: UITableView!
    
    var pockets : [Pocket] = [Pocket]()
    var userUID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pocketTableView.delegate = self
        pocketTableView.dataSource = self

        // Register CustomPocketCell.xib
        pocketTableView.register(UINib(nibName: "CustomPocketCell", bundle: nil), forCellReuseIdentifier: "customPocketCell")
        
        setupNavigationBar()
        
        getUserUID()
        loadPocketsData()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "My pockets"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func getUserUID() {
        guard let uid = Auth.auth().currentUser?.uid else {
            fatalError("Could not get user UID")
        }
        
        userUID = uid
    }
    
    private func loadPocketsData() {
        let pocketsDB = Database.database().reference().child("Pockets")
        
        pocketsDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            
            let pocketName = snapshotValue["name"]
            let pocketContributors = snapshotValue["contributors"] as! Dictionary<String, Any>
            
            let pocket = Pocket()
            pocket.name = pocketName as! String
            pocket.contributors = pocketContributors
            
            self.pockets.append(pocket)
            self.pocketTableView.reloadData()
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customPocketCell", for: indexPath) as! CustomPocketCell
        cell.pocketTextLabel.text = pockets[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pockets.count
    }
    
    @IBAction func addPocketBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Pocket", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newPocketName = textField.text!
            if newPocketName != "" {
                let pocketsDB = Database.database().reference().child("Pockets").childByAutoId()
                
                // Rate is hard coded for now V1.0
                let rate = 50
                let data = ["name": "\(newPocketName)", "contributors": [self.userUID : rate]] as [String : Any]
                
                print(newPocketName)
                pocketsDB.setValue(data) { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                    
                    // Update Users Data in Firebase with new Pocket
                    if let uid = Auth.auth().currentUser?.uid {
                        let userDB = Database.database().reference().child("Users").child(uid).child("pockets")
                        let pocketData = [pocketsDB.key : true]
                        userDB.updateChildValues(pocketData)
                    }
                }
            } else {
                self.displayAlert("Please specify pocket name")
            }
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New pocket"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayAlert(_ message : String) {
        let alert = UIAlertController(title: "Oops something's wrong", message: "\(message)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    

}
