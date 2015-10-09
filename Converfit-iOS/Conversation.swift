import UIKit
import CoreData

@objc(Conversation)
public class Conversation: _Conversation {

    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict:NSDictionary, aLastUpdate:String, existe:Bool){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        //Guardamos el conversationKey
        if let aConversationKey = aDict.objectForKey("conversation_key") as? String{
            conversationKey = aConversationKey
        }else{
            conversationKey = ""
        }
        
        //Guardamos el fname
        if let aFname = aDict.objectForKey("user_fname") as? String{
            fname = aFname
        }else{
            fname = ""
        }
        
        //Guardamos el lname
        if let aLname = aDict.objectForKey("user_lname") as? String{
            lname = aLname
        }else{
            lname = ""
        }
        
        //Guardamos el user_key y el avatar
        if let aUserDict = aDict.objectForKey("user") as? NSDictionary{
            if let aUserKey = aUserDict.objectForKey("user_key") as? String{
                userKey = aUserKey
            }else{
                userKey = ""
            }
            
            //Tenemos que convertir la imagen que nos descargamos a Data
            if let  dataImage = aUserDict.objectForKey("avatar") as? String{
                if let decodedData = NSData(base64EncodedString: dataImage, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                    avatar = decodedData
                }
            }
            
            //Guardamos el conection status
            if let aConnectionStatus = aUserDict.objectForKey("connection-status") as? String{
                conectionStatus = aConnectionStatus
            }
        }
        
        //Guardamos el indicador de mensaje nuevo
        if let aFlagNewMessageUser = aDict.objectForKey("flag_new_message_brand") as? String{
            if(aFlagNewMessageUser == "1"){
                flagNewUserMessage = true
            }else{
                flagNewUserMessage = false
            }
        }else{
            flagNewUserMessage = false
        }
        
        if let aLastMessage = aDict.objectForKey("last_message") as? String{
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
        }else{
            lastMessage = ""
        }
        
        if let aCreationLastMessage = aDict.objectForKey("last_update") as? String{
            creationLastMessage = aCreationLastMessage
        }else{
            creationLastMessage = ""
        }
        
        if(existe){
            lastUpdate = aLastUpdate
        }else{
            lastUpdate = "0"
        }
        
        coreDataStack.saveContext()
    }

    
    //Metodo que devuelve todo el listado de Conversaciones
    static func devolverListConversations() -> [ConversationsModel]{
        
        var listadoConversations = [ConversationsModel]()
        
        let request = NSFetchRequest(entityName: Conversation.entityName())
        let miShorDescriptor = NSSortDescriptor(key: "creationLastMessage", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
        
        for brand in results{
            let aux = ConversationsModel(modelo: brand)
            listadoConversations.append(aux)
        }
        return listadoConversations
    }

    //Borra todos los Brands
    static func borrarAllConversations() -> Bool{
        var borrado = false
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.returnsObjectsAsFaults = false
        let allConversations = try! coreDataStack.context.executeFetchRequest(request)
        
        if allConversations.count > 0 {
            
            for result: AnyObject in allConversations{
                coreDataStack.context.deleteObject(result as! NSManagedObject)
            }
            borrado = true
            coreDataStack.saveContext()
        }
        return borrado
    }
    
    static func borrarConversationConSessionKey(conversationKey:String, update:Bool){
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let conversacion = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
        
        if conversacion.count > 0 {
            
            for result: AnyObject in conversacion{
                coreDataStack.context.deleteObject(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
            if(!update){
               // Messsage.borrarMensajesConConverstaionKey(conversationKey)
            }
        }
    }
    
    static func cambiarFlagNewMessageUserConversation(conversationKey:String, nuevo:Bool){
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let conversacion = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
        
        if conversacion.count > 0 {
            
            for result: Conversation in conversacion{
                if(result.flagNewUserMessage == true){
                    result.flagNewUserMessage = false
                    //PostServidor.updateNewMessageFlag(conversationKey)
                }else{
                    result.flagNewUserMessage = nuevo
                }
            }
            coreDataStack.saveContext()
        }
    }
    
    static func updateLastMesssageConversation(conversationKey:String, ultimoMensaje:String, fechaCreacion:String){
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let conversacion = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
        
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
    static func existeConversacion(conversationKey:String) -> Bool{
        var existe = false
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        let listConversaciones = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
        if(listConversaciones.count > 0){
            existe = true
        }
        
        return existe
    }
    
    //Metodo para modificar el lastUpdate propio de una conversacion
    static func modificarLastUpdate(conversationKey:String, aLastUpdate:String){
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)
        request.returnsObjectsAsFaults = false
        
        let listConversaciones = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
        if (listConversaciones.count > 0){
            for conversacion in listConversaciones {
                conversacion.lastUpdate = aLastUpdate
            }
            coreDataStack.saveContext()
        }
    }
    
    static func obtenerLastUpdate(conversationKey:String) -> String{
        var lastUpdate = "0"
        let request = NSFetchRequest(entityName: Conversation.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        request.returnsObjectsAsFaults = false
        
        var listConversaciones = (try! coreDataStack.context.executeFetchRequest(request)) as! [Conversation]
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
    
}
