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
        let request = NSMutableURLRequest(URL: NSURL(string: urlServidor)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        let logOutTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                guard data != nil else {
                    print("no data found: \(error)")
                    return
                }
                
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.MutableContainers]) as? NSDictionary {
                        if let resultCode = json.objectForKey("result") as? Int{
                            if(resultCode == 1){
                            //LogOutCorrecto
                            }
                        }
                    }
                } catch{
                    
                }
        }
        logOutTask.resume()
    }
    
    //Funcion para cuando la sessionKey no es valida te desloguea
    static func desLoguearBorrarDatos(){
        //Paramos el timer
        myTimer.invalidate()
        //Borramos el badgeIcon de la App
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //Borramos el sessionkey que teniamos guardado
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("session_key")
        defaults.removeObjectForKey("last_update")
        defaults.removeObjectForKey("last_update_follower")
        defaults.removeObjectForKey("conversations_last_update")
        defaults.removeObjectForKey("last_update_brands_notifications")
        borrarAllCoreData()
        irPantallaLogin = false
    }
    
    //Funcion para borarr los datos de CoreData
    static func borrarAllCoreData(){
        Conversation.borrarAllConversations()
        User.borrarAllUsers()
        Messsage.borrarAllMessages()
        TimeLine.borrarAllPost()
    }

    //Funcion para comprobar si nos deslogueamos segun el errorCode
    static func comprobarDesloguear(errorCode:String) -> Bool{
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
            if(dbErrorContador == 5){
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
