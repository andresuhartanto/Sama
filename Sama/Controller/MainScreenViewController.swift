//
//  MainScreenViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 20/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var testData = ["Water Bill", "Netflix", "Groceries", "Internet", "Maintenace", "Cleaning Lady", "Cat food"]
    
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set as delegate and data source
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
        // Register CustomItemCell.xib
        itemTableView.register(UINib(nibName: "CustomItemCell", bundle: nil), forCellReuseIdentifier: "customItemCell")
        
        // Register CustomHeader.xib
        let nib = UINib(nibName: "CustomHeader", bundle: nil)
        itemTableView.register(nib, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(red: 60/255, green: 193/255, blue: 246/255, alpha: 1.0)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Cell Creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customItemCell", for: indexPath) as! CustomItemCell
        
        cell.itemNameTextLabel.text = testData[indexPath.row]
        cell.priceTextLabel.text = "$42"
        cell.profileImageView.image = UIImage(named: "username_icon")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }

}
