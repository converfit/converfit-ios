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
        let serverString = Utils.returnUrlWS("access")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue {
                    //(self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(error)
                    //self.mostrarAlerta()
                    print("error: \(error)")
                }else{
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
            })
        }
    }
    
    //MARK: - Enable or disable Chat
    static func getStatusChat(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=brand_webchat_status&session_key=\(sessionKey)"
        let serverString = Utils.returnUrlWS("webchat")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue {
                    //(self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(error)
                    //self.mostrarAlerta()
                    print("error: \(error)")
                }else{
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
            })
        }
    }

    
    //Cambiamos el valor de new_messsage_flag en la BBDD a true
    static func updateNewMessageFlag(_ conversationKey:String){
        let defaults = UserDefaults.standard
        let serverString = Utils.returnUrlWS("conversations")
        if let sessionKey = defaults.string(forKey: "session_key"), url = URL(string: serverString){
           let params = "action=update_conversation_flag&session_key=\(sessionKey)&conversation_key=\(conversationKey)&new_message_flag=\(0)&app_version=\(appVersion)&app=\(app)"
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                /*if error!.code == -1005{
                    self.updateNewMessageFlag(conversationKey)
                 }*/
                if error != TypeOfError.NOERROR.rawValue {
                    //(self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(error)
                    //self.mostrarAlerta()
                    print("error: \(error)")
                }else{
                    if let dataResultado = json["data"] as? Dictionary<String, AnyObject>{
                        let lastUpdate = dataResultado["last_update"] as? String ?? ""
                        Utils.saveLastUpdate(lastUpdate)
                    }
                    let resultCode = json["result"] as? Int ?? 0
                    if resultCode == 1{
                        //No hacemos nada
                    }else{//resultCode == 0
                        //let errorCode = json["error_code"] as? String ?? ""
                    }
                }
            })
        }
    }
    
    //MARK: - Push Actualizar modelos
    //Metodo que llama al WS GetConversation para obtener los datos de la conversacion cuando llega una push
    static func getConversacion(_ conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=get_conversation&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=1&app=\(app)"
        let serverString = Utils.returnUrlWS("conversations")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue {
                    //(self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(error)
                    //self.mostrarAlerta()
                }else{
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
            })
        }
    }
    
    //Metodo que se llama para actualizar el modelo cuando nos llega una notificacion nueva
    static func updateMensaje(_ conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Conversation.obtenerLastUpdate(conversationKey)
        let params = "action=list_messages&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=\(lastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let serverString = Utils.returnUrlWS("conversations")
        if let url = URL(string: serverString){
            ServerUtils.getAsyncResponse(method: HTTPMethods.POST.rawValue, url: url, params: params, completionBlock: { (error, json) in
                if error != TypeOfError.NOERROR.rawValue {
                    //(self.tituloAlert,self.mensajeAlert) = Utils().establecerTituloMensajeAlert(error)
                    //self.mostrarAlerta()
                }else{
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
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationChat), object: nil, userInfo:nil)
                                    }
                                }
                            }
                        })
                    }
                }
            })
        }
    }
}
