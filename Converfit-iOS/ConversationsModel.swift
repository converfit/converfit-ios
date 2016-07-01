//
//  ConversationsModel.swift
//  Citious-IOs
//
//  Created by Manuel Citious on 20/5/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class ConversationsModel {
    var conversationKey = ""
    var avatar:UIImage?
    var lastMessageCreation = ""
    var flagNewMessageUser = false
    var lastMessage = ""
    var userkey = ""
    var fname = ""
    var lname = ""
    var connectionStatus = ""
    
    
    //Inicializador con los datos que obtenemos de CoreData
    convenience init(modelo:Conversation){
        self.init()
        conversationKey = modelo.conversationKey
        fname = modelo.fname
        lname = modelo.lname
        userkey = modelo.userKey
        lastMessage = modelo.lastMessage
        lastMessageCreation = modelo.creationLastMessage
        flagNewMessageUser = modelo.flagNewUserMessage.boolValue
        connectionStatus = modelo.conectionStatus
        
        //Tenemos que convertir la imagen que nos descargamos a UImage
        if let foto = UIImage(data: modelo.avatar as Data) {
            avatar = foto
        }
    }
}
