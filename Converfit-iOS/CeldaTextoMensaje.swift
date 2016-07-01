//
//  CeldaTextoMensaje.swift
//  Citious_IOs
//
//  Created by Manuel Martinez Gomez on 5/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class CeldaTextoMensaje: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var hora: UILabel!
    @IBOutlet weak var vistaRedondeada: UIView!
    @IBOutlet weak var botonReenviarMensaje: UIButton!
    @IBOutlet weak var traillingConstrait: NSLayoutConstraint!
    @IBOutlet weak var mensaje: UITextView!
    @IBOutlet weak var senderBrandName: UILabel!
    @IBOutlet weak var traillingContraitNombre: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vistaRedondeada.layer.cornerRadius = 5
        botonReenviarMensaje.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
