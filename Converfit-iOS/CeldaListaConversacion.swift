//
//  CeldaListaConversacion.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 1/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class CeldaListaConversacion: UITableViewCell {

    //Outlets
    @IBOutlet weak var avatarImagen: UIImageView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageCreation: UILabel!
    @IBOutlet weak var imagenNuevoMensaje: UIImageView!
    @IBOutlet weak var assignedTo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
