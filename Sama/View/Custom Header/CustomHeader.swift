//
//  CustomHeader.swift
//  Sama
//
//  Created by Andre Suhartanto on 24/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit
import Firebase

class CustomHeader: UITableViewHeaderFooterView, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var pocketBtn: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet var contributorsCollectionView: UICollectionView!
    var activePocket : Pocket = Pocket()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        contributorsCollectionView.delegate = self
        contributorsCollectionView.dataSource = self
        
        // Register xib
        contributorsCollectionView.register(UINib(nibName: "ContributorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customContributorCell")
        
        setActivePocket()
    }
    
    private func setActivePocket() {
        getActivePocket { (pocket) in
            self.activePocket = pocket
            self.contributorsCollectionView.reloadData()
        }
    }
    
    // Contributor CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contributorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "customContributorCell", for: indexPath) as! ContributorCollectionViewCell
        
        return contributorCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    
    @IBAction func pocketBtnPressed(_ sender: UIButton) {
        
    }
}
