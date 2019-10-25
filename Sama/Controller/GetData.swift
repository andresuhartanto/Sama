//
//  GetActivePocket.swift
//  Sama
//
//  Created by Andre Suhartanto on 08/10/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import Foundation
import Firebase

func getActivePocket(completion: @escaping (Pocket) -> Void) {
    let ref = Database.database().reference()
    ref.child("Users").child(Data.userUID).child("activePocket").observe(.childAdded) { (snapshot) in
        let pocketRef = ref.child("Pockets").child(snapshot.key)
        pocketRef.observe(.value) { (pocketSnapshot) in
            let snapshotValue = pocketSnapshot.value as! Dictionary<String, Any>
            
            let pocket = Pocket()
            let pocketID = pocketSnapshot.key
            let pocketName = snapshotValue["name"]
            let pocketContributors = snapshotValue["contributors"] as! Dictionary<String, Any>
            
           loadContributors(ref, pocketContributors)
            
            pocket.pocketID = pocketID
            pocket.name = pocketName as! String
            pocket.contributors = pocketContributors
            
            if let items = snapshotValue["items"] as? [String : Bool] {
                loadData(items, ref) { (itemArray) in
                    
                    pocket.items = itemArray
                    
                    completion(pocket)
                }
            }
            completion(pocket)
        }
    }
}

func loadContributors(_ ref : DatabaseReference, _ pocketContributors : [String : Any]) {
    var contributors : [Contributor] = [Contributor]()
    let contributor = Contributor()
    
    for (userUID, rate) in pocketContributors {
        ref.child("Users").child(userUID).observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            
            contributor.name = snapshotValue["name"] as! String
            contributor.userUID = userUID
//            contributor.profileImageURL = snapshotValue["profile"]
            contributor.rate = rate as! Int
            
            contributors.append(contributor)
            
            Data.contributors = contributors
        }
    }
    
    print(contributors)
    
}

func loadData(_ items : [String : Bool], _ ref : DatabaseReference, completion: @escaping ([Item]) -> Void) {
    var itemArray : [Item] = [Item]()
    
    for item in items {
        let itemRef = ref.child("Items").child(item.key)
        let itemObject = Item()
        
        itemRef.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let ownerID = snapshotValue["owner"] as! Dictionary<String, Bool>
            
            itemObject.id = item.key
            itemObject.name = snapshotValue["name"] as! String
            itemObject.price = snapshotValue["price"] as! String
            itemObject.owner = ownerID.first!.key
            
            completion(itemArray)
        }
        
        itemArray.append(itemObject)
    }
    
    completion(itemArray)
}
