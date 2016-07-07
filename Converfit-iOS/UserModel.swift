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
            if let foto = UIImage(data: avatarString as Data){
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
    convenience init(aDict: Dictionary<String, AnyObject>){
        self.init()
        //Guardamos el avatar
        if let dataImage = aDict["user_avatar"] as? String{
            if let decodedData = Data(base64Encoded: dataImage, options: .endLineWithCarriageReturn){
                if let foto = UIImage(data: decodedData) {
                    avatar = foto
                }
            }
        }
        
        connectionStatus = aDict["connection-status"] as? String ?? ""
        
        horaConectado = aDict["last_connection"] as? String ?? ""
        
        lastPageTitle = aDict["last_page_title"] as? String ?? ""
        
        userKey = aDict["user_key"] as? String ?? ""
        
        userName = aDict["user_name"] as? String ?? ""
        
        coreDataStack.saveContext()
    }
}
