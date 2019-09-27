//
//  AddNewPocketViewController.swift
//  Sama
//
//  Created by Andre Suhartanto on 27/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit

class AddNewPocketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pocketTableView: UITableView!
    
//    var pockets : [Pocket] = [Pocket]()
    var pockets = [
                    [
                    "name" : "Home",
                    "id" : "abcs",
                    "items" : [
                    "id" : "itemidddd",
                    "name" : "Laundry",
                    "price" : "450",
                    "owner" : "USER UID"
                    ],
                    "contibutors" : [
                    "id" : "CONTRIBUTOR ID",
                    "userId" : "CONTIBUTOR USER ID",
                    "rate" : 50
                    ]]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pocketTableView.delegate = self
        pocketTableView.dataSource = self

        // Register CustomPocketCell.xib
        pocketTableView.register(UINib(nibName: "CustomPocketCell", bundle: nil), forCellReuseIdentifier: "customPocketCell")
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "My pockets"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customPocketCell", for: indexPath) as! CustomPocketCell
        cell.pocketTextLabel.text = pockets[indexPath.row]["name"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pockets.count
    }
    
    @IBAction func addPocketBtnPressed(_ sender: UIBarButtonItem) {
    }
    

}
