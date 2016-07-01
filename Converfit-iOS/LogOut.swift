//
//  LogOut.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 8/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit
var dbErrorContador = 0

class LogOut {

    static func desLoguear(){
        let sessionKey = Utils.getSessionKey()
        let params = "action=logout&session_key=\(sessionKey)&app=\(app)"
        let urlServidor = Utils.returnUrlWS("access")
        var request = URLRequest(url: URL(string: urlServidor)!)
        let session = URLSession.shared()
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let logOutTask = session.dataTask(with: request) { (data, response, error) -> Void in
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.mutableContainers]) as? Dictionary<String, AnyObject> {
                        let resultCode = json["result"] as? Int ?? 0
                        if resultCode == 1{
                            //LogOutCorrecto
                        }
                    }
                } catch{
                    
                }
        }
        logOutTask.resume()
    }
    
    //Funcion para cuando la sessionKey no es valida te desloguea
    static func desLoguearBorrarDatos(){
        //Borramos el badgeIcon de la App
        UIApplication.shared().applicationIconBadgeNumber = 0
        //Borramos el sessionkey que teniamos guardado
        let defaults = UserDefaults.standard()
        defaults.removeObject(forKey: "session_key")
        defaults.removeObject(forKey: "last_update")
        defaults.removeObject(forKey: "last_update_follower")
        defaults.removeObject(forKey: "conversations_last_update")
        defaults.removeObject(forKey: "last_update_brands_notifications")
        borrarAllCoreData()
        irPantallaLogin = false
        myTimerLeftMenu.invalidate()
    }
    
    //Funcion para borarr los datos de CoreData
    static func borrarAllCoreData(){
        _=Conversation.borrarAllConversations()
        _=User.borrarAllUsers()
        _=Messsage.borrarAllMessages()
        _=TimeLine.borrarAllPost()
    }

    //Funcion para comprobar si nos deslogueamos segun el errorCode
    static func comprobarDesloguear(_ errorCode:String) -> Bool{
        var desloguear = false
        
        switch errorCode{
        case "session_key_not_valid":
            errorCheckSession = "session_key_not_valid"
            desloguear = true
            irPantallaLogin = true
            break
        case "system_closed":
            bloquearSistema = true
            errorCheckSession = "system_closed"
            desloguear = true
            irPantallaLogin = true
            break
        case "version_not_valid":
            bloquearSistema = true
            errorCheckSession = "version_not_valid"
            desloguear = true
            irPantallaLogin = true
            break
        case "db_connection_error":
            dbErrorContador += 1
            if dbErrorContador == 5{
                desloguear = true
                irPantallaLogin = true
            }
            break
        case "admin_not_active":
            errorCheckSession = "admin_not_active"
            desloguear = true
            irPantallaLogin = true
            break
        default:
            break
        }
        return desloguear
    }

    
}
