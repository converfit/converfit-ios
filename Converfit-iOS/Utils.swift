//
//  Utils.swift
//  Converfit-iOS
//
//  Created by Manuel Martinez Gomez on 8/10/15.
//  Copyright © 2015 Citious Team SL. All rights reserved.
//

import UIKit

class Utils {
    
    //MARK: - ULR WebServices
    static func returnUrlWS(modelo:String) -> String{
        var resultado = ""
        let accesoServidor = "pruebas" // "produccion" o "pruebas"
        
        switch accesoServidor{
        case "pruebas":
            let rutaServidor = "http://server.converfit.com/"
            if(modelo == "access"){
                resultado = rutaServidor + "android/1.0.0/models/access/model.php"
            }else if(modelo == "conversations"){
                resultado = rutaServidor + "ios/1.0.0/models/conversations/model.php"
            }else if(modelo == "brand_notifications"){
                resultado = rutaServidor + "ios/1.0.0/models/brand_notifications/model.php"
            }else if(modelo == "users"){
                resultado = rutaServidor + "ios/1.0.0/models/users/model.php"
            }else if(modelo == "brands"){
                resultado = rutaServidor + "ios/1.0.0/models/brands/model.php"
            }else if(modelo == "pdf"){
                resultado = rutaServidor + "resources/message_files/"
            }
            break
        default:
            let rutaServidor = "http://server.converfit.com/"
            if(modelo == "access"){
                resultado = rutaServidor + "ios/1.0.0/models/access/model.php"
            }else if(modelo == "conversations"){
                resultado = rutaServidor + "ios/1.0.0/models/conversations/model.php"
            }else if(modelo == "brand_notifications"){
                resultado = rutaServidor + "ios/1.0.0/models/brand_notifications/model.php"
            }else if(modelo == "users"){
                resultado = rutaServidor + "ios/1.0.0/models/users/model.php"
            }else if(modelo == "brands"){
                resultado = rutaServidor + "ios/1.0.0/models/brands/model.php"
            }else if(modelo == "pdf"){
                resultado = rutaServidor + "resources/message_files/"
            }
            break
        }
        return resultado
    }
    
    //MARK: - Title and Message erros
    static func returnTitleAndMessageAlert(errorCode:String) ->(String,String){
        var title = ""
        var message = ""
        
        switch errorCode{
            case "system_closed":
                title = "Error"
                message = "El sistema está temporalmente cerrado. Por favor inténtelo mas tarde."
                break
            case "version_not_valid":
                title = "Es necesario actualizar"
                message = "La versión que estás utilizando no está soportada. Es necesario actualizar."
                break
            case "db_connection_error":
                title = "Error"
                message = "Ha ocurrido un error en la conexión con la base de datos."
                break
            case "session_key_not_valid":
                title = "Error"
                message = "Su sesión ha expirado."
                break
            case "input_data_missing":
                title = "Error"
                message = "Falta alguno de los campos del formulario."
                break
            case "email_in_use":
                title = "Error"
                message = "El email está siendo usado por otro usuario."
                break
            case "email_not_in_use":
                title = "Error"
                message = "El email no está siendo usado por ningún usuario."
                break
            case "email_not_valid":
                title = "Error"
                message = "No existe un usuario con ese email."
                break
            case "email_or_password_not_valid":
                title = "Email o contraseña no válidos"
                message = "El correo electrónico o la contraseña que has introducido no son válidos."
                break
            case "old_password_not_valid":
                title = "Error"
                message = "La contraseña no es válida."
                break
            case "list_conversations_empty":
                title = "Error"
                message = "El usuario no tiene conversaciones abiertas."
                break
            case "list_brands_empty":
                title = "Error"
                message = "El listado de marcas está vacío."
                break
            case "list_favorites_empty":
                title = "Error"
                message = "No se han obtenido resultados de la búsqueda."
                break
            case "brand_username_not_valid":
                title = "Error"
                message = "El nombre de usuario de la empresa no ha sido encontrado."
                break
            case "brand_not_active":
                title = "Error"
                message = "La empresa ha sido desactivada y no puede recibir mensajes."
                break
            case "brand_in_user_favorites":
                title = "Error"
                message = "La empresa ya se encuentra en el listado de favoritos."
                break
            case "brand_not_in_user_favorites":
                title = "Error"
                message = "La empresa ya no se encuentra en el listado de favoritos."
                break
            case "user_not_active":
                title = "Error"
                message = "Es necesario verificar su correo, revise su correo y verifique su cuenta. Puede que el correo llegue a su cuenta de Spam."
                break
            case "list_messages_empty":
                title = "Error"
                message = "La parte de conversación no tiene ningún mensaje."
                break
            case "conversation_permission_denied":
                title = "Error"
                message = "El usuario no tiene permisos para acceder a esta conversación."
                break
            case "conversation_not_active":
                title = "Error"
                message = "La conversación ya había sido desactivada."
                break
            case "campos_vacios":
                title = "Error en el formulario"
                message = "Debe rellenar todos los campos del formulario."
                break
            case "formato_email":
                title = "Error en el formulario"
                message = "Email no válido, tiene que tener el formato de email."
                break
            case "formato_nombre":
                title = "Error en el formulario"
                message = "El nombre tiene un formato no válido, tiene que tener entre 3 y 50 caracteres."
                break
            case "formato_apellidos":
                title = "Error en el formulario"
                message = "Los apellidos tiene un formato no válido, tiene que tener entre 3 y 50 caracteres."
                break
            case "formato_contraseña":
                title = "Error en el formulario"
                message = "La contraseña tiene un formato no válido, tiene que tener entre 4 y 25 caracteres."
                break
            case "pass_actual":
                title = "Error en el formulario"
                message = "La contraseña actual tiene un formato no válido, tiene que tener entre 4 y 25 caracteres."
                break
            case "pass_nueva":
                title = "Error en el formulario"
                message = "La contraseña nueva tiene un formato no válido, tiene que tener entre 4 y 25 caracteres."
                break
            case "errorLLamada":
                title = "Error al realizar la llamada"
                message = "No se ha podido realizar la llamada. Por favor inténtelo mas tarde."
                break
            case "user_blocked":
                title = "Usuario bloqueado"
                message = "Su cuenta de usuario ha sido bloqueada para esta marca."
                break
            case "conversation_closed":
                title = "Conversación cerrada"
                message = "La conversación a la que intenta acceder ha sido cerrada."
                break
            case "conversation_cancelled":
                title = "Conversación cancelada"
                message = "La conversación a la que intenta acceder ha sido cancelada."
                break
            case "admin_not_active":
                title = "Administrador no activo"
                message = "El administrador se encuentra inactivo."
            case "user_key_not_valid":
                title = "Usuario no válido"
                message = "El usuario que ha seleccionado no es válido."
            default:
                title = "Error de conexión"
                message = "No se ha podido establecer conexión con el servidor. Compruebe si tiene acceso a la red y vuelva a intentarlo."
            break
        }
        return (title,message)
    }
    
    //MARK: Email is valid
    static func emailIsValid(email:String) ->Bool{
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let range = email.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil ? true : false
        return result
    }
    
    //MARK: - Save last Update
    static func saveLastUpdate(lasUpdate:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(lasUpdate, forKey: "last_update")
    }
    
    static func getLastUpdate() -> String{
        var lastUpdate = "0"
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastUp = defaults.stringForKey("last_update"){
            lastUpdate = lastUp
        }
        return lastUpdate
    }
    
    //MARK: - Save conversations_last_update
    static func saveConversationsLastUpdate(lasUpdate:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(lasUpdate, forKey: "conversations_last_update")
    }
    
    static func getConversationsLastUpdate() -> String{
        var lastUpdate = "0"
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastUp = defaults.stringForKey("conversations_last_update"){
            lastUpdate = lastUp
        }
        return lastUpdate
    }
    
    //MARK: - Save follower last update
    static func saveLastUpdateFollower(lasUpdate:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(lasUpdate, forKey: "last_update_follower")
    }
    
    //Funcion para optener el last_update
    static func getLastUpdateFollower() -> String{
        var lastUpFavoritos = "0"
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastUp = defaults.stringForKey("last_update_follower"){
            lastUpFavoritos = lastUp
        }
        return lastUpFavoritos
    }
    
    //MARK: - Save session_key
    static func saveSessionKey(sessionKey:String){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sessionKey, forKey: "session_key")
    }
    
    static func getSessionKey() -> String{
        var lastUpFavoritos = "0"
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lastUp = defaults.stringForKey("session_key"){
            lastUpFavoritos = lastUp
        }
        return lastUpFavoritos
    }

    //MARK: - LogOut
    //Funcion para cuando la sessionKey no es valida te desloguea
    static func desLoguear(){
        //Borramos el badgeIcon de la App
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //Borramos el sessionkey que teniamos guardado
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("session_key")
        defaults.removeObjectForKey("last_update")
        defaults.removeObjectForKey("last_update_favorito")
        defaults.removeObjectForKey("conversations_last_update")
    }
    
    //MARK: - Strings
    static func removerEspaciosBlanco(textoConEspacios:String) ->String{
        var cadena = textoConEspacios
        cadena = textoConEspacios.stringByReplacingOccurrencesOfString(" ", withString: "+", options: [], range: nil)
        return cadena
    }
    
    static func quitarEspacios(textoConEspacios:String) ->String{
        var cadena = textoConEspacios
        cadena = textoConEspacios.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        return cadena
    }
    
    static func quitarSaltosdeLinea(textoConEspacios:String) ->String{
        var cadena = textoConEspacios
        cadena = textoConEspacios.stringByReplacingOccurrencesOfString("\n", withString: "", options: [], range: nil)
        return cadena
    }
}
