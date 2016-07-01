//
//  CeldaCargarMensajesAnteriores.swift
//  Citious_IOs
//
//  Created by Manuel Citious on 13/4/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class CeldaCargarMensajesAnteriores: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var btnCargarMensajesAnteriores: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnCargarMensajesAnteriores.layer.cornerRadius = 5
        btnCargarMensajesAnteriores.tintColor = UIColor.black()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
