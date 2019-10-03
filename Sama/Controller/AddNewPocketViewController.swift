//
//  AddNewPocketViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 27/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class AddNewPocketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pocketTableView: UITableView!
    
    var pockets : [Pocket] = [Pocket]()
    var userUID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pocketTableView.delegate = self
        pocketTableView.dataSource = self
        
        // remove line seperator
        pocketTableView.separatorStyle = .none

        // Register CustomPocketCell.xib
        pocketTableView.register(UINib(nibName: "CustomPocketCell", bundle: nil), forCellReuseIdentifier: "customPocketCell")
        
        setupNavigationBar()
        
        loadPocketsData()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "My pockets"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func loadPocketsData() {
        let userPocketsRef = Database.database().reference().child("Users").child(userUID).child("pockets")
        userPocketsRef.observe(.childAdded) { (userPocketSnapshot) in
            
            let pocketsRef = Database.database().reference().child("Pockets").child(userPocketSnapshot.key)
            pocketsRef.observeSingleEvent(of: .value) { (pocketSnapshot) in
                let snapshotValue = pocketSnapshot.value as! Dictionary<String, Any>

                let pocketID = pocketSnapshot.key
                let pocketName = snapshotValue["name"]
                let pocketContributors = snapshotValue["contributors"] as! Dictionary<String, Any>

                let pocket = Pocket()
                pocket.pocketID = pocketID
                pocket.name = pocketName as! String
                pocket.contributors = pocketContributors

                self.pockets.append(pocket)
                self.pocketTableView.reloadData()
            }
        }
    }
    
    private func deletePocket(_ indexPath : IndexPath) {
        let pocketID = self.pockets[indexPath.row].pocketID
        let ref = Database.database().reference()
        // Removing from Pockets DB
        ref.child("Pockets").child(pocketID).removeValue()
        // Removing pocket ref from user
        ref.child("Users").child(self.userUID).child("pockets").child(pocketID).removeValue()
        // removing from Array
        self.pockets.remove(at: indexPath.row)
        
        self.pocketTableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customPocketCell", for: indexPath) as! CustomPocketCell
        
        // SwipeCellKit Delegate
        cell.delegate = self
        
        cell.pocketTextLabel.text = pockets[indexPath.row].name
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pockets.count
    }
    
    // Updating active pocket data once cell/pocket is selected
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(pockets[indexPath.row].name)
        updateActivePocket(pockets[indexPath.row].pocketID)
    }
    
    private func updateActivePocket(_ pocketID : String) {
        let userDB = Database.database().reference().child("Users").child(userUID).child("activePocket")
        let activePocketData = [pocketID: true]
        
        userDB.updateChildValues(activePocketData) { (error, ref) in
            if error != nil {
                fatalError("Could not set activePocket data")
            } else {
                print("Active Pocket is set! Go back to main screen now!")
            }
        }
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

// MARK - SwipeCellKit Delegate

extension AddNewPocketViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let alert = UIAlertController(title: "Delete Pocket", message: "Are you sure you want to delete this pocket?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                self.deletePocket(indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
}
