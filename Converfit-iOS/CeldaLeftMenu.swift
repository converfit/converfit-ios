//
//  CeldaLeftMenu.swift
//  Converfit-iOS
//
//  Created by Manuel Citious on 16/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class CeldaLeftMenu: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var imagenAvatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var hora: UILabel!
    @IBOutlet weak var imagenConnectionStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagenAvatar.layer.cornerRadius = imagenAvatar.frame.height/2
        imagenAvatar.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
