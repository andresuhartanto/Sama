//
//  MainScreenViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 20/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

protocol CustomHeaderDelegate {
    func contibutorsList(data: String)
}

class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var itemTableView: UITableView!
    var items : [Item] = [Item]()
    var pocketName: String = "Create Pocket \u{2193}"
    var totalAmount : Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set as delegate and data source
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
        // Get and set userUID
        Data.userUID = getuserID()
        
        // Register CustomItemCell.xib
        itemTableView.register(UINib(nibName: "CustomItemCell", bundle: nil), forCellReuseIdentifier: "customItemCell")
        
        // Register CustomHeader.xib
        let nib = UINib(nibName: "CustomHeader", bundle: nil)
        itemTableView.register(nib, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        
        loadActivePocket()
    }
    
    
    private func calculateTotal() {
        var total : Float = 0
        for item in Data.activePocket.items {
            if let price = Float(item.price) {
                total += price
            }
        }
        
        totalAmount = total
    }
    
    // Get Active Pocket
    private func loadActivePocket() {
        getActivePocket { (pocket) in
            if pocket.name != "" {
                self.pocketName = pocket.name
            }
            
            Data.activePocket = pocket
            self.createPocketBtn()
            self.calculateTotal()
            
            self.itemTableView.reloadData()
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
            destinationVC.userUID = Data.userUID
        }
    }
    
    // Header Creation
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
        header.pocketBtn.setTitle("Home", for: .normal)
        header.totalLabel.text = "$ \(String(format: "%.2f", totalAmount))"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }
    
    // Cell Creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customItemCell", for: indexPath) as! CustomItemCell
        
        cell.delegate = self
        
        cell.itemNameTextLabel.text = Data.activePocket.items[indexPath.row].name
        cell.priceTextLabel.text = Data.activePocket.items[indexPath.row].price
        cell.profileImageView.image = UIImage(named: "username_icon")
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.activePocket.items.count
    }
    
    // Add button funtions
    
    @IBAction func addItemBtnPressed(_ sender: UIBarButtonItem) {
        addItem()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil {
          return true
       } else {
          return false
       }
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
                
                // Safety check for the price
                if self.isValidPrice(newItemPrice) {
                    guard let price = Float(newItemPrice) else {
                        fatalError("Could not convert price to Float")
                    }
                    
                    let data = ["name": "\(newItemName)", "price" : String(format: "%.2f", price), "owner": [Data.userUID : true]] as [String : Any]
                    
                    itemsDB.setValue(data) { (error, ref) in
                        if error != nil {
                            print(error!)
                        }
                        
                        // Update pocket Data in Firebase with new item
                        let pocketDB = Database.database().reference().child("Pockets").child(Data.activePocket.pocketID).child("items")
                        let itemData = [itemsDB.key : true]
                        pocketDB.updateChildValues(itemData)
                        
                        self.itemTableView.reloadData()
                    }
                } else {
                    self.displayAlert("\(newItemPrice) is not a valid price")
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
            alertTextField.keyboardType = .decimalPad
            priceTextField = alertTextField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func isValidPrice(_ priceStr : String) -> Bool {
        if priceStr == "." {
            return false
        }
        
        switch priceStr.filter({ $0 == "." }).count {
        // if there is no dot (.)
        case 0:
            return true
        // if there is one dot (.)
        case 1:
            return true
        // if there are more than one dot (.)
        default:
            return false
        }
    }
    
    private func displayAlert(_ message : String) {
        let alert = UIAlertController(title: "Oops something's wrong", message: "\(message)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func deleteItem(_ indexPath : IndexPath) {
        let itemID = Data.activePocket.items[indexPath.row].id
        let ref = Database.database().reference()
        // Removing from Items DB
        ref.child("Items").child(itemID).removeValue()
        // Removing item ref from pocket
        ref.child("Pockets").child(Data.activePocket.pocketID).child("items").child(itemID).removeValue()
        // removing from Array
        Data.activePocket.items.remove(at: indexPath.row)
        
        self.itemTableView.reloadData()
    }
    
}

// MARK - SwipeCellKit Delegate

extension MainScreenViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                self.deleteItem(indexPath)
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
