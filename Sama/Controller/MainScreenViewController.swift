//
//  MainScreenViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 20/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase

class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var testData = ["Water Bill", "Netflix", "Groceries", "Internet", "Maintenace", "Cleaning Lady", "Cat food"]
    
    @IBOutlet weak var itemTableView: UITableView!
    var userUID: String = ""
    var activePocket : Pocket = Pocket()
    var items : [Item] = [Item]()
    var pocketName: String = "Create Pocket \u{2193}"
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set as delegate and data source
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
        // Get userUID
        userUID = getuserID()
        
        // Register CustomItemCell.xib
        itemTableView.register(UINib(nibName: "CustomItemCell", bundle: nil), forCellReuseIdentifier: "customItemCell")
        
        // Register CustomHeader.xib
        let nib = UINib(nibName: "CustomHeader", bundle: nil)
        itemTableView.register(nib, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        
        loadActivePocket()
        loadItems()
        
    }
    
    private func loadItems() {
        
    }
    
    // Get Active Pocket
    private func loadActivePocket() {
        getActivePocket { (pocket) in
            if pocket.name != "" {
                self.pocketName = pocket.name
            }
            
            self.activePocket = pocket
            self.createPocketBtn()
        }
    }
    
    // Create Pocket Button
    private func createPocketBtn() {
        let button = PocketButton()
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        button.backgroundColor = UIColor(red: 95/255, green: 147/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = button.frame.size.height / 2
        button.addTarget(self, action: #selector(pocketBtnPressed), for: .touchUpInside)
        button.setTitle(pocketName, for: .normal)
        navigationItem.titleView = button
    }
    
    @objc func pocketBtnPressed() {
        performSegue(withIdentifier: "goToAddNewPocket", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddNewPocket" {
            let destinationVC = segue.destination as! AddNewPocketViewController
            destinationVC.userUID = userUID
        }
    }
    
    // Header Creation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
        header.pocketBtn.setTitle("Home", for: .normal)
        header.firstUserNameLabel.text = "Andre"
        header.secondUserNameLabel.text = "Jerome"
        header.totalLabel.text = "$1.980"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }
    
    // Cell Creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customItemCell", for: indexPath) as! CustomItemCell
        
        cell.itemNameTextLabel.text = testData[indexPath.row]
        cell.priceTextLabel.text = "$42"
        cell.profileImageView.image = UIImage(named: "username_icon")
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }
    
    // Add button funtions
    
    @IBAction func addItemBtnPressed(_ sender: UIBarButtonItem) {
        addItem()
    }
    
    private func addItem() {
        var nameTextField = UITextField()
        var priceTextField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newItemName = nameTextField.text!
            let newItemPrice = priceTextField.text!
            if newItemName != "" && newItemName != "" {
                let itemsDB = Database.database().reference().child("Items").childByAutoId()
                
                let data = ["name": "\(newItemName)", "price" : "\(newItemPrice)", "owner": [self.userUID : true]] as [String : Any]
                
                itemsDB.setValue(data) { (error, ref) in
                    if error != nil {
                        print(error!)
                    }
                    
                    // Update pocket Data in Firebase with new item
                    let pocketDB = Database.database().reference().child("Pockets").child(self.activePocket.pocketID).child("items")
                    let itemData = [itemsDB.key : true]
                    pocketDB.updateChildValues(itemData)
                }
            } else {
                self.displayAlert("Please specify a value")
            }
            
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item"
            nameTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Price"
            priceTextField = alertTextField
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
