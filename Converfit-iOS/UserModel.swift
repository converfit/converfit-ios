//
//  UserModel.swift
//  CitiousManager-IOs
//
//  Created by Manuel Citious on 18/8/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class UserModel {
    //MARK: - Variables
    var avatar:UIImage?
    var connectionStatus = ""
    var horaConectado = ""
    var lastPageTitle = ""
    var userKey = ""
    var userName = ""
    
    
    //Inicializador con los datos que obtenemos de CoreData
    //Inicializador de Favoritos
    convenience init(modelo:User){
        self.init()
        if let avatarString = modelo.avatar{
            if let foto = UIImage(data: avatarString){
                avatar = foto
            }
        }
        
        if let aConnectionStatus = modelo.connectionStatus{
            connectionStatus = aConnectionStatus
        }
        if let anHoraConectado = modelo.horaConectado{
            horaConectado = anHoraConectado
        }
        if let aLastPageTitle = modelo.lastPageTitle{
            lastPageTitle = aLastPageTitle
        }
        if let anUserKey = modelo.userKey{
            userKey = anUserKey
        }
        if let anUserName = modelo.userName{
            userName = anUserName
        }
        
    }
    
    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict:NSDictionary){
        self.init()
        //Guardamos el avatar
        if let dataImage = aDict.objectForKey("user_avatar") as? String{
            if let decodedData = NSData(base64EncodedString: dataImage, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                if let foto = UIImage(data: decodedData) {
                    avatar = foto
                }
            }
        }
        
        if let aConnectionStatus = aDict.objectForKey("connection-status") as? String{
            connectionStatus = aConnectionStatus
        }
        
        if let anHoraConectado = aDict.objectForKey("last_connection") as? String{
            horaConectado = anHoraConectado
        }
        
        if let aLastPageTitle = aDict.objectForKey("last_page_title") as? String{
            lastPageTitle = aLastPageTitle
        }
        
        if let anUserKey = aDict.objectForKey("user_key") as? String{
            userKey = anUserKey
        }
        
        if let anUserName = aDict.objectForKey("user_name") as? String{
            userName = anUserName
        }
        
        coreDataStack.saveContext()
    }

}
