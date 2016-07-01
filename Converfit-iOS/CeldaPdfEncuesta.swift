//
//  CeldaPdfEncuesta.swift
//  Citious-IOs
//
//  Created by Manuel Citious on 26/6/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class CeldaPdfEncuesta: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var vistaContenedora: UIView!
    @IBOutlet weak var mensaje: UILabel!
    @IBOutlet weak var hora: UILabel!
    @IBOutlet weak var accion: UILabel!
    @IBOutlet weak var senderBrandName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagen.layer.cornerRadius = 5
        vistaContenedora.layer.cornerRadius = 5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
