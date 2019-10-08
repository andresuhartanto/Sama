//
//  GetActivePocket.swift
//  Sama
//
//  Created by Andre Suhartanto on 08/10/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import Foundation
import Firebase

var userUID = getuserID()

func getActivePocket(completion: @escaping (Pocket) -> Void) {
    let ref = Database.database().reference()
    let pocket = Pocket()
    ref.child("Users").child(userUID).child("activePocket").observe(.childAdded) { (snapshot) in
        let pocketRef = ref.child("Pockets").child(snapshot.key)
        pocketRef.observeSingleEvent(of: .value) { (pocketSnapshot) in
            let snapshotValue = pocketSnapshot.value as! Dictionary<String, Any>

            let pocketID = pocketSnapshot.key
            let pocketName = snapshotValue["name"]
            let pocketContributors = snapshotValue["contributors"] as! Dictionary<String, Any>
            
            if let items = snapshotValue["items"] as? [String : Bool] {
                loadData(items, ref) { (itemArray) in
                    pocket.pocketID = pocketID
                    pocket.name = pocketName as! String
                    pocket.contributors = pocketContributors
                    pocket.items = itemArray
                    
                    completion(pocket)
                }
            }
        }
    }
    completion(pocket)
}

func loadData(_ items : [String : Bool], _ ref : DatabaseReference, completion: @escaping ([Item]) -> Void) {
    var itemArray : [Item] = [Item]()
    
    for item in items {
        let itemRef = ref.child("Items").child(item.key)
        let itemObject = Item()
        
        itemRef.observe(.value) { (snapshot) in
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
