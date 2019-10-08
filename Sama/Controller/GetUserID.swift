//
//  GetUserID.swift
//  Sama
//
//  Created by Andre Suhartanto on 08/10/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import Foundation
import Firebase

func getuserID() -> String {
    guard let uid = Auth.auth().currentUser?.uid else {
        fatalError("Could not get user UID")
    }
    
    return uid
}
