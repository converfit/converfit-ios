import UIKit
import CoreData

@objc(Conversation)
public class Conversation: _Conversation {

    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict: Dictionary<String, AnyObject>, aLastUpdate:String, existe:Bool){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        //Guardamos el conversationKey
        conversationKey = aDict["conversation_key"] as? String ?? ""
        
        //Guardamos el fname
        fname = aDict["user_fname"] as? String ?? ""
        
        //Guardamos el lname
        lname = aDict["user_lname"] as? String ?? ""
        
        //Guardamos el user_key y el avatar
        if let aUserDict = aDict["user"] as? Dictionary<String, AnyObject>{
            userKey = aUserDict["user_key"] as? String ?? ""
            
            //Tenemos que convertir la imagen que nos descargamos a Data
            if let  dataImage = aUserDict["avatar"] as? String{
                if let decodedData = Data(base64Encoded: dataImage, options: .encodingEndLineWithCarriageReturn){
                    avatar = decodedData
                }
            }
            
            //Guardamos el conection status
            conectionStatus = aUserDict["connection-status"] as? String ?? ""
        }
        
        //Guardamos el indicador de mensaje nuevo
        let aFlagNewMessageUser = aDict["flag_new_message_brand"] as? String ?? "0"
        flagNewUserMessage = (aFlagNewMessageUser == "1") ? true : false
        
        let aLastMessage = aDict["last_message"] as? String ?? ""
        if(aLastMessage == "[::image]"){
            lastMessage = "📷"
        }else if (aLastMessage == "[::document]"){
            lastMessage = "📎"
        }else if (aLastMessage == "[::poll]"){
            lastMessage = "📋"
        }else if (aLastMessage == "[::video]"){
            lastMessage = "📹"
        }else{
            lastMessage = aLastMessage
        }
        
        creationLastMessage = aDict["last_update"] as? String ?? ""
        
        lastUpdate = (existe) ? aLastUpdate : "0"
        
        coreDataStack.saveContext()
    }

    
    //Metodo que devuelve todo el listado de Conversaciones
    static func devolverListConversations() -> [ConversationsModel]{
        
        var listadoConversations = [ConversationsModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        let miShorDescriptor = SortDescriptor(key: "creationLastMessage", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        
        for brand in results{
            let aux = ConversationsModel(modelo: brand)
            listadoConversations.append(aux)
        }
        return listadoConversations
    }

    //Borra todos los Brands
    static func borrarAllConversations() -> Bool{
        var borrado = false
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.returnsObjectsAsFaults = false
        let allConversations = try! coreDataStack.context.fetch(request)
        
        if allConversations.count > 0 {
            
            for result: AnyObject in allConversations{
                coreDataStack.context.delete(result as! NSManagedObject)
            }
            borrado = true
            coreDataStack.saveContext()
        }
        return borrado
    }
    
    static func borrarConversationConSessionKey(_ conversationKey:String, update:Bool){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let conversacion = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        
        if conversacion.count > 0 {
            
            for result: AnyObject in conversacion{
                coreDataStack.context.delete(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
            if(!update){
               // Messsage.borrarMensajesConConverstaionKey(conversationKey)
            }
        }
    }
    
    static func cambiarFlagNewMessageUserConversation(_ conversationKey:String, nuevo:Bool){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let conversacion = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        
        if conversacion.count > 0 {
            
            for result: Conversation in conversacion{
                if(result.flagNewUserMessage == true){
                    result.flagNewUserMessage = false
                    PostServidor.updateNewMessageFlag(conversationKey)
                }else{
                    result.flagNewUserMessage = nuevo
                }
            }
            coreDataStack.saveContext()
        }
    }
    
    static func updateLastMesssageConversation(_ conversationKey:String, ultimoMensaje:String, fechaCreacion:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let conversacion = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        
        if conversacion.count > 0 {
            
            for result: Conversation in conversacion{
                result.lastMessage = ultimoMensaje
                result.creationLastMessage = fechaCreacion
            }
            coreDataStack.saveContext()
        }
    }
    
    static func numeroMensajesSinLeer() -> Int{
        var numero = 0
        let listadoConversaciones = devolverListConversations()
        for conversacion:ConversationsModel in listadoConversaciones{
            if(conversacion.flagNewMessageUser == true){
                numero += 1
            }
        }
        return numero
    }
    
    //Metodo para comprobar si ya habia una conversacion con una converstaionKey determinada
    static func existeConversacion(_ conversationKey:String) -> Bool{
        var existe = false
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let listConversaciones = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        if(listConversaciones.count > 0){
            existe = true
        }
        
        return existe
    }
    
    //Metodo para modificar el lastUpdate propio de una conversacion
    static func modificarLastUpdate(_ conversationKey:String, aLastUpdate:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)
        request.returnsObjectsAsFaults = false
        
        let listConversaciones = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        if (listConversaciones.count > 0){
            for conversacion in listConversaciones {
                conversacion.lastUpdate = aLastUpdate
            }
            coreDataStack.saveContext()
        }
    }
    
    static func obtenerLastUpdate(_ conversationKey:String) -> String{
        var lastUpdate = "0"
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        var listConversaciones = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        if (listConversaciones.count > 0){
            lastUpdate = listConversaciones[0].lastUpdate
        }
        
        return lastUpdate
    }
    
    //Devuelve la hora del ultimo mensaje enviado
    static func devolverHoraUltimaConversacion() ->String {
        var listConversaciones = devolverListConversations()
        if(listConversaciones.count == 0){
            //return Utils.fechaActualToString()
            return "0"
        }else{
            return listConversaciones[listConversaciones.count - 1].lastMessageCreation
        }
    }
    
    //Devuelve si un userKey tiene conversacion o no
    static func existeConversacionDeUsuario(_ userKey:String) -> (Bool, String){
        var existe = false
        var conversationKey = ""
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = Predicate(format: "userKey = %@", userKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let listConversaciones = (try! coreDataStack.context.fetch(request)) as! [Conversation]
        if (listConversaciones.count > 0){
            existe = true
            conversationKey = listConversaciones[0].conversationKey
        }
        
        return (existe, conversationKey)
    }
}
