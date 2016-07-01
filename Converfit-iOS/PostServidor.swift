//
//  PostServidor.swift
//  Citious-IOs
//
//  Created by Manuel Citious on 19/5/15.
//  Copyright (c) 2015 Citious Team. All rights reserved.
//

import UIKit

class PostServidor {
    
    //MARK: - Asincrono
    static func actualizarDeviceKey(){
        let sessionKey = Utils.getSessionKey()
        let deviceKey = Utils.getDeviceKey()
        let lastUpdate = Utils.getLastUpdate()
        let params = "action=check_session&session_key=\(sessionKey)&device_key=\(deviceKey)&last_update=\(lastUpdate)&system=\(sistema)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let actualizarDeviceTask = session.dataTask(with: request) { (data, response, error) -> Void in
           
            if data != nil{
                if error != nil{
                    if error!.code == -1005{
                        self.actualizarDeviceKey()
                    }
                }else{
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                            let resultCode = json["result"] as? Int ?? 0
                            if resultCode == 1{
                                dbErrorContador = 0
                                if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                                    let lastUpdate = dataResultado["last_update"] as? String ?? ""
                                    Utils.saveLastUpdate(lastUpdate)
                                }
                            }else{
                                let errorCode = json["error_code"] as? String ?? ""
                                errorCheckSession = errorCode
                                _=LogOut.comprobarDesloguear(errorCheckSession)
                            }
                        }
                    } catch{
                
                    }
                }
            }
        }
        actualizarDeviceTask.resume()
    }
    
    //MARK: - Enable or disable Chat
    static func getStatusChat(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=brand_webchat_status&session_key=\(sessionKey)"
        let urlServidor = Utils.returnUrlWS("webchat")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let estatusMenuLeftTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        dbErrorContador = 0
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            let menuLeftStatus = dataResultado["brand_webchat_status"] as? String ?? "0"
                            Utils.saveStatusLeftMenu(menuLeftStatus)
                        }
                    }else{
                        //No hacemos nada
                    }
                }
            } catch{
                
            }
        }
        estatusMenuLeftTask.resume()
    }

    
    //Cambiamos el valor de new_messsage_flag en la BBDD a true
    static func updateNewMessageFlag(_ conversationKey:String){
        let defaults = UserDefaults.standard()
        let sessionKey = defaults.string(forKey: "session_key")!
        let urlServidor = Utils.returnUrlWS("conversations")
        let params = "action=update_conversation_flag&session_key=\(sessionKey)&conversation_key=\(conversationKey)&new_message_flag=\(0)&app_version=\(appVersion)&app=\(app)"
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let updateNewMessageFlagTask = session.dataTask(with: request) { (data, response, error) -> Void in
            if data != nil{
                if error != nil {
                    if error!.code == -1005{
                        self.updateNewMessageFlag(conversationKey)
                    }
                }else{
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                            if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                                let lastUpdate = dataResultado["last_update"] as? String ?? ""
                                Utils.saveLastUpdate(lastUpdate)
                            }
                            let resultCode = json["result"] as? Int ?? 0
                            if(resultCode == 1){
                                //No hacemos nada
                            }else{//resultCode == 0
                                //let errorCode = json["error_code"] as? String ?? ""
                            }
                        }
                    } catch{
                        
                    }
                }
            }
        }
        updateNewMessageFlagTask.resume()
    }
    
    //MARK: - Push Actualizar modelos
    //Metodo que llama al WS GetConversation para obtener los datos de la conversacion cuando llega una push
    static func getConversacion(_ conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=get_conversation&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=1&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let getConversacionTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        dbErrorContador = 0
                        if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                            DispatchQueue.main.async(execute: { () -> Void in
                                if let conversacion = dataResultado["conversation"] as? Dictionary<String, AnyObject>{
                                    let lastUpdateAntiguo = Conversation.obtenerLastUpdate(conversationKey)
                                    let existe = Conversation.existeConversacion(conversationKey)
                                    Conversation.borrarConversationConSessionKey(conversationKey, update: true)
                                    _=Conversation(aDict: conversacion, aLastUpdate: lastUpdateAntiguo, existe: existe)
                                    self.updateMensaje(conversationKey)
                                }
                            })
                        }
                    }
                }
            } catch{
                
            }
        }
        getConversacionTask.resume()
    }
    
    //Metodo que se llama para actualizar el modelo cuando nos llega una notificacion nueva
    static func updateMensaje(_ conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Conversation.obtenerLastUpdate(conversationKey)
        let params = "action=list_messages&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=\(lastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let updateMensajeTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>{
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        dbErrorContador = 0
                        DispatchQueue.main.async(execute: { () -> Void in
                            if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                                let lastUp = dataResultado["last_update"] as? String ?? ""
                                Conversation.modificarLastUpdate(conversationKey, aLastUpdate: lastUp)
                                let needToUpdate = dataResultado["need_to_update"] as? Bool ?? true
                                if needToUpdate{
                                    Messsage.borrarMensajesConConverstaionKey(conversationKey)
                                    if let messagesArray = dataResultado["messages"] as? [Dictionary<String, AnyObject>]{
                                        for dict in messagesArray{
                                            _=Messsage(aDict: dict, aConversationKey: conversationKey)
                                        }
                                        NotificationCenter.default().post(name: Notification.Name(rawValue: notificationChat), object: nil, userInfo:nil)
                                    }
                                }
                            }
                        })
                    }
                }
            } catch{
                
            }
        }
        updateMensajeTask.resume()

    }
}
