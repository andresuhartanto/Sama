//
//  CustomPocketCell.swift
//  Sama
//
//  Created by Andre Suhartanto on 27/09/2019.
//  Copyright © 2019 Andre Suhartanto. All rights reserved.
//

import UIKit

class CustomPocketCell: UITableViewCell {
    
    @IBOutlet var pocketImageView: UIImageView!
    @IBOutlet var pocketTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
