//
//  CeldaImagenMensajes.swift
//  Citious_IOs
//
//  Created by Manuel Martinez Gomez on 5/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class CeldaImagenMensajes: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var hora: UILabel!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var botonReenviarMensaje: UIButton!
    @IBOutlet weak var traillingConstraitImagen: NSLayoutConstraint!
    @IBOutlet weak var traillingConstraitHora: NSLayoutConstraint!
    @IBOutlet weak var senderBrandName: UILabel!
    @IBOutlet weak var traillingContraitNombre: NSLayoutConstraint!
    @IBOutlet weak var playImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagen.layer.cornerRadius = 5
        botonReenviarMensaje.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
