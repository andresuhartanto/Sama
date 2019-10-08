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

            
            pocket.pocketID = pocketID
            pocket.name = pocketName as! String
            pocket.contributors = pocketContributors
            
            completion(pocket)
        }
    }
    completion(pocket)
}
