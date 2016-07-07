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
    static func returnUrlWS(_ modelo:String) -> String{
        var resultado = ""
        let accesoServidor = "produccion" // "produccion" o "pruebas"
        
        switch accesoServidor{
        case "pruebas":
            let rutaServidor = "http://server.converfit.com/"
            if modelo == "access"{
                resultado = rutaServidor + "ios/1.0.0/models/access/model.php"
            }else if modelo == "conversations"{
                resultado = rutaServidor + "ios/1.0.0/models/conversations/model.php"
            }else if modelo == "brand_notifications"{
                resultado = rutaServidor + "ios/1.0.0/models/brand_notifications/model.php"
            }else if modelo == "brands"{
                resultado = rutaServidor + "ios/1.0.0/models/users/model.php"
            }else if modelo == "webchat"{
                resultado = rutaServidor + "ios/1.0.0/models/brands/model.php"
            }else if modelo == "pdf"{
                resultado = rutaServidor + "resources/message_files/"
            }
            break
        default:
            let rutaServidor = "http://server.converfit.com/"
            if modelo == "access"{
                resultado = rutaServidor + "ios/1.0.0/models/access/model.php"
            }else if modelo == "conversations"{
                resultado = rutaServidor + "ios/1.0.0/models/conversations/model.php"
            }else if modelo == "brand_notifications"{
                resultado = rutaServidor + "ios/1.0.0/models/brand_notifications/model.php"
            }else if modelo == "brands"{
                resultado = rutaServidor + "ios/1.0.0/models/users/model.php"
            }else if modelo == "webchat"{
                resultado = rutaServidor + "ios/1.0.0/models/brands/model.php"
            }else if modelo == "pdf"{
                resultado = rutaServidor + "resources/message_files/"
            }
            break
        }
        return resultado
    }
    
    //MARK: - Title and Message erros
    static func returnTitleAndMessageAlert(_ errorCode:String) ->(String,String){
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
    static func emailIsValid(_ email:String) ->Bool{
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let range = email.range(of: emailRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    //MARK: - Save last Update
    static func saveLastUpdate(_ lasUpdate:String){
        let defaults = UserDefaults.standard
        defaults.set(lasUpdate, forKey: "last_update")
    }
    
    static func getLastUpdate() -> String{
        var lastUpdate = "0"
        let defaults = UserDefaults.standard
        if let lastUp = defaults.string(forKey: "last_update"){
            lastUpdate = lastUp
        }
        return lastUpdate
    }
    
    //MARK: - Save conversations_last_update
    static func saveConversationsLastUpdate(_ lasUpdate:String){
        let defaults = UserDefaults.standard
        defaults.set(lasUpdate, forKey: "conversations_last_update")
    }
    
    static func getConversationsLastUpdate() -> String{
        var lastUpdate = "0"
        let defaults = UserDefaults.standard
        if let lastUp = defaults.string(forKey: "conversations_last_update"){
            lastUpdate = lastUp
        }
        return lastUpdate
    }
    
    //MARK: - Save follower last update
    static func saveLastUpdateFollower(_ lasUpdate:String){
        let defaults = UserDefaults.standard
        defaults.set(lasUpdate, forKey: "last_update_follower")
    }
    
    //Funcion para optener el last_update
    static func getLastUpdateFollower() -> String{
        var lastUpFavoritos = "0"
        let defaults = UserDefaults.standard
        if let lastUp = defaults.string(forKey: "last_update_follower"){
            lastUpFavoritos = lastUp
        }
        return lastUpFavoritos
    }
    
    //MARK: - Save brandsNotifications last update
    static func saveLastUpdateBrandsNotifications(_ lasUpdate:String){
        let defaults = UserDefaults.standard
        defaults.set(lasUpdate, forKey: "last_update_brands_notifications")
    }
    
    //Funcion para optener el brandsNotifications last_update
    static func getLastUpdateBrandsNotifications() -> String{
        var lastUpBrandsNotifications = "0"
        let defaults = UserDefaults.standard
        if let lastUp = defaults.string(forKey: "last_update_brands_notifications"){
            lastUpBrandsNotifications = lastUp
        }
        return lastUpBrandsNotifications
    }

    //MARK: - Save session_key
    static func saveSessionKey(_ sessionKey:String){
        let defaults = UserDefaults.standard
        defaults.set(sessionKey, forKey: "session_key")
    }
    
    static func getSessionKey() -> String{
        var lastUpFavoritos = "0"
        let defaults = UserDefaults.standard
        if let lastUp = defaults.string(forKey: "session_key"){
            lastUpFavoritos = lastUp
        }
        return lastUpFavoritos
    }
    
    //MARK: - Save session_key
    static func saveDeviceKey(_ deviceKey:String){
        let defaults = UserDefaults.standard
        defaults.set(deviceKey, forKey: "devide_key")
    }
    
    static func getDeviceKey() -> String{
        var deviceKey = "dont_allow"
        let defaults = UserDefaults.standard
        if let device = defaults.string(forKey: "devide_key"){
            deviceKey = device
        }
        return deviceKey
    }
    
    
    //MARK: - Save status left menu
    static func saveStatusLeftMenu(_ saveStatusLeftMenu:String){
        let defaults = UserDefaults.standard
        defaults.set(saveStatusLeftMenu, forKey: "statusLeftMenu")
    }
    
    static func getStatusLeftMenu() -> String{
        var statusLeftMenu = "0"
        let defaults = UserDefaults.standard
        if let status = defaults.string(forKey: "statusLeftMenu"){
            statusLeftMenu = status
        }
        return statusLeftMenu
    }
    
    //MARK: - Strings
    static func removerEspaciosBlanco(_ textoConEspacios:String) ->String{
        var cadena = textoConEspacios
        cadena = textoConEspacios.replacingOccurrences(of: " ", with: "+", options: [], range: nil)
        return cadena
    }
    
    static func quitarEspacios(_ textoConEspacios:String) ->String{
        var cadena = textoConEspacios
        cadena = textoConEspacios.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        return cadena
    }
    
    static func quitarSaltosdeLinea(_ textoConEspacios:String) ->String{
        var cadena = textoConEspacios
        cadena = textoConEspacios.replacingOccurrences(of: "\n", with: "", options: [], range: nil)
        return cadena
    }
    
    //Funcion que devuelve una acitivity indicator
    static func crearActivityLoading(_ width:Double, heigth:Double) -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: width, height: heigth)
        activityIndicator.color = UIColor.darkGray()
        
        return activityIndicator
    }
    
    static func guardarIdLogin(_ id:String){
        let defaults = UserDefaults.standard
        defaults.set(id, forKey: "id_login")
    }
    
    //Funcion para obtener el id del usuario logado
    static func obtenerIdLogin() -> String{
        var id = "0"
        let defaults = UserDefaults.standard
        if let aID = defaults.string(forKey: "id_login"){
            id = aID
        }
        return id
    }
    
    //Funcion para guardar el fname del usuario logado
    static func guardarFname(_ fname:String){
        let defaults = UserDefaults.standard
        defaults.set(fname, forKey: "fname")
    }
    
    //Funcion para obtener el fname del usuario logado
    static func obtenerFname() -> String{
        var fname = ""
        let defaults = UserDefaults.standard
        if let aFname = defaults.string(forKey: "fname"){
            fname = aFname
        }
        return fname
    }
    
    //Funcion para guardar el lname del usuario logado
    static func guardarLname(_ lname:String){
        let defaults = UserDefaults.standard
        defaults.set(lname, forKey: "lname")
    }
    
    //Funcion para obtener el fname del usuario logado
    static func obtenerLname() -> String{
        var lname = ""
        let defaults = UserDefaults.standard
        if let aLname = defaults.string(forKey: "lname"){
            lname = aLname
        }
        return lname
    }
    
    //Funcion para decodificar el video a un NSData
    static func decodificarVideo(_ videoBase64:String) -> Data?{
        return Data(base64Encoded: videoBase64, options: .endLineWithCarriageReturn)
    }
    
    //Metodo para modificar la apariencia
    static func customAppear(_ vc:UIViewController){
        vc.navigationController?.navigationBar.barTintColor = Colors.returnRedConverfit()
        vc.navigationController?.navigationBar.tintColor = UIColor.white()
        vc.view.backgroundColor = Colors.returnGrisFondo()
    }
}

//MARK: - Obtener tipo de dispositivo
public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
