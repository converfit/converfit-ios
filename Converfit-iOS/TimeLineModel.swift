//
//  TimeLineModel.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 14/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class TimeLineModel {
    
    var userKey = ""
    var avatar:UIImage?
    var userName = ""
    var created = ""
    var content = ""
    
    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(modelo:TimeLine){
        self.init()
        userKey = modelo.userKey
        //Tenemos que convertir la imagen que nos descargamos a UImage
        if let foto = UIImage(data: modelo.userAvatar) {
            avatar = foto
        }
        userName = modelo.userName
        created = modelo.created
        content = modelo.content
    }
}
