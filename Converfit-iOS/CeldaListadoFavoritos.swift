//
//  CeldaListadoFavoritos.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 8/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class CeldaListadoFavoritos: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var imagenAvatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    
    //MARK: - LifeCycle
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
