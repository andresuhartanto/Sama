//
//  User.swift
//  Sama
//
//  Created by Andre Suhartanto on 27/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import Foundation

class User {
    var id : String = ""
    var name : String = ""
    var email : String = ""
    var pockets : [Pocket] = [Pocket]()
    var activePocket : Pocket = Pocket()
}
