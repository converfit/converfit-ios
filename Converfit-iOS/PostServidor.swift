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
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let actualizarDeviceTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
           
            if(data != nil){
                if(error != nil){
                    if(error!.code == -1005){
                        self.actualizarDeviceKey()
                    }
                }else{
                    do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                            if let resultCode = json.objectForKey("result") as? Int{
                                if(resultCode == 1){
                                    dbErrorContador = 0
                                    //Guardamos el last update del usuario
                                    if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                        if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                                            Utils.saveLastUpdate(lastUpdate)
                                        }
                                    }

                                }else{//resultCode == 0
                                    if let dataResultado = json.objectForKey("error_code") as? String{
                                        errorCheckSession = dataResultado
                                        LogOut.comprobarDesloguear(errorCheckSession)
                                    }
                                }
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
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let estatusMenuLeftTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            dbErrorContador = 0
                            if let data = json.objectForKey("data") as? NSDictionary{
                                if let menuLeftStatus = data.objectForKey("brand_webchat_status") as? String{
                                    Utils.saveStatusLeftMenu(menuLeftStatus)
                                }
                            }
                        }else{
                            //MostrarAlerta error
                        }
                    }
                }
            } catch{
                
            }
        }
        estatusMenuLeftTask.resume()
    }

    
    //Cambiamos el valor de new_messsage_flag en la BBDD a true
    static func updateNewMessageFlag(conversationKey:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        let sessionKey = defaults.stringForKey("session_key")!
        let urlServidor = Utils.returnUrlWS("conversations")
        let params = "action=update_conversation_flag&session_key=\(sessionKey)&conversation_key=\(conversationKey)&new_message_flag=\(0)&app_version=\(appVersion)&app=\(app)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let updateNewMessageFlagTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if(data != nil){
                if(error != nil){
                    if(error!.code == -1005){
                        self.updateNewMessageFlag(conversationKey)
                    }
                }else{
                    do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                                    Utils.saveLastUpdate(lastUpdate)
                                }
                            }
                            if let resultCode = json.objectForKey("result") as? Int{
                                if(resultCode == 1){
                                    //No hacemos nada
                                }else{//resultCode == 0
                                    if let _ = json.objectForKey("error_code") as? String{
                                        //No hacemos nada
                                    }
                                }
                            }
                        }
                    } catch{
                        
                    }
                }
            }
        }
        updateNewMessageFlagTask.resume()
    }
    
    /*
    //Cambiamos el valor de new_messsage_flag en la BBDD a true
    static func updateNewMessageFlag(conversationKey:String){
        let downloadQueue:NSOperationQueue = {
            let queue = NSOperationQueue()
            queue.name = "Download queue"
            queue.maxConcurrentOperationCount = 60
            return queue
            }()
        let defaults = NSUserDefaults.standardUserDefaults()
        let sessionKey = defaults.stringForKey("session_key")!
        let urlServidor = Utils.devolverURLservidor("conversations")
        let params = "action=update_conversation_flag&session_key=\(sessionKey)&conversation_key=\(conversationKey)&new_message_flag=\(0)&app_version=\(appVersion)&app=\(app)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: downloadQueue) { (response, data, error) -> Void in
            if(error != nil){
                if(error.code == -1005){
                    self.updateNewMessageFlag(conversationKey)
                }
            }else{
                if(data.length > 0){
                    let JSONObjetcs = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    //Guardamos el last update del usuario
                    if let dataResultado = JSONObjetcs.objectForKey("data") as? NSDictionary{
                        if let lastUpdate = dataResultado.objectForKey("last_update") as? String{
                            Utils.guardarLastUpdate(lastUpdate)
                        }
                    }
                }
            }
        }
    }
    
*/
    
    
    //MARK: - Push Actualizar modelos
    
    //Metodo que llama al WS GetConversation para obtener los datos de la conversacion cuando llega una push
    static func getConversacion(conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let params = "action=get_conversation&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=1&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let getConversacionTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            dbErrorContador = 0
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                if let conversacion = dataResultado.objectForKey("conversation") as? NSDictionary{
                                    let lastUpdateAntiguo = Conversation.obtenerLastUpdate(conversationKey)
                                    let existe = Conversation.existeConversacion(conversationKey)
                                    Conversation.borrarConversationConSessionKey(conversationKey, update: true)
                                    _=Conversation(aDict: conversacion, aLastUpdate: lastUpdateAntiguo, existe: existe)
                                }
                            }
                        }
                    }
                }
            } catch{
                
            }
            self.updateMensaje(conversationKey)
        }
        getConversacionTask.resume()

    }
    /*static func getConversacion(session:String, conversationKey:String){
        let conversationQueue:NSOperationQueue = {
            let queue = NSOperationQueue()
            queue.name = "mensaje queue"
            queue.maxConcurrentOperationCount = 60
            return queue
            }()
        
        let urlServidor = Utils.devolverURLservidor("conversations")
        let params = "action=get_conversation&session_key=\(session)&conversation_key=\(conversationKey)&last_update=1&app=\(app)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: conversationQueue) { (response, data, error) -> Void in
            if(data.length > 0){
                let JSONObjetcs:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if let codigoResultado = JSONObjetcs.objectForKey("result") as? Int{
                    if(codigoResultado == 1){
                        dbErrorContador = 0
                        if let dataResultado = JSONObjetcs.objectForKey("data") as? NSDictionary{
                            if let conversacion = dataResultado.objectForKey("conversation") as? NSDictionary{
                                let lastUpdateAntiguo = Conversation.obtenerLastUpdate(conversationKey)
                                let existe = Conversation.existeConversacion(conversationKey)
                                Conversation.borrarConversationConSessionKey(conversationKey, update: true)
                                Conversation(aDict: conversacion, aLastUpdate: lastUpdateAntiguo, existe: existe)
                            }
                        }
                    }
                }
            }
            self.updateMensaje(session, conversationKey: conversationKey)
        }
    }
    */
    
    //Metodo que se llama para actualizar el modelo cuando nos llega una notificacion nueva
    static func updateMensaje(conversationKey:String){
        let sessionKey = Utils.getSessionKey()
        let lastUpdate = Conversation.obtenerLastUpdate(conversationKey)
        let params = "action=list_messages&session_key=\(sessionKey)&conversation_key=\(conversationKey)&last_update=\(lastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("conversations")
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let updateMensajeTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard data != nil else {
                print("no data found: \(error)")
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                    if let resultCode = json.objectForKey("result") as? Int{
                        if(resultCode == 1){
                            dbErrorContador = 0
                            if let dataResultado = json.objectForKey("data") as? NSDictionary{
                                if let lastUp = dataResultado.objectForKey("last_update") as? String{
                                    Conversation.modificarLastUpdate(conversationKey, aLastUpdate: lastUp)
                                }
                                if let needToUpdate = dataResultado.objectForKey("need_to_update") as? Bool{
                                    if (needToUpdate){
                                        Messsage.borrarMensajesConConverstaionKey(conversationKey)
                                        if let messagesArray = dataResultado.objectForKey("messages") as? [NSDictionary]{
                                            //Llamamos por cada elemento del array de empresas al constructor
                                            for dict in messagesArray{
                                                _=Messsage(aDict: dict, aConversationKey: conversationKey)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(notificationChat, object: nil, userInfo:nil)
                }
            } catch{
                
            }
            //self.updateMensaje(conversationKey: conversationKey)
        }
        updateMensajeTask.resume()

    }
    /*static func updateMensaje(session:String, conversationKey:String){
        let messajeQueue:NSOperationQueue = {
            let queue = NSOperationQueue()
            queue.name = "mensaje queue"
            queue.maxConcurrentOperationCount = 60
            return queue
            }()
        
        var lastUpdate = Conversation.obtenerLastUpdate(conversationKey)
        let urlServidor = Utils.devolverURLservidor("conversations")
        let params = "action=list_messages&session_key=\(session)&conversation_key=\(conversationKey)&last_update=\(lastUpdate)&offset=\(0)&limit=\(1000)&app_version=\(appVersion)&app=\(app)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: messajeQueue) { (response, data, error) -> Void in
            if(data.length > 0){
                let JSONObjetcs:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if let codigoResultado = JSONObjetcs.objectForKey("result") as? Int{
                    if(codigoResultado == 1){
                        dbErrorContador = 0
                        if let dataResultado = JSONObjetcs.objectForKey("data") as? NSDictionary{
                            if let lastUp = dataResultado.objectForKey("last_update") as? String{
                                Conversation.modificarLastUpdate(conversationKey, aLastUpdate: lastUp)
                            }
                            if let needToUpdate = dataResultado.objectForKey("need_to_update") as? Bool{
                                if (needToUpdate){
                                    Messsage.borrarMensajesConConverstaionKey(conversationKey)
                                    if let messagesArray = dataResultado.objectForKey("messages") as? [NSDictionary]{
                                        //Llamamos por cada elemento del array de empresas al constructor
                                        for dict in messagesArray{
                                            Messsage(aDict: dict, aConversationKey: conversationKey)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let defaultCenter: Void = NSNotificationCenter.defaultCenter().postNotificationName(notificationChat, object: nil, userInfo:nil)
            }
        }
    }
*/
}
