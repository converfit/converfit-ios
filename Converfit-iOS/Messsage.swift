import UIKit
import CoreData

@objc(Messsage)
public class Messsage: _Messsage {
    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict:NSDictionary, aConversationKey:String){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        conversationKey = aConversationKey
        //Guardamos el message key
        if let aMessage = aDict.objectForKey("message_key") as? String{
            messageKey = aMessage
        }
        
        //Guardamos quien envio el mensaje
        if let aSender = aDict.objectForKey("sender") as? String{
            sender = aSender
        }
        
        //Guardamos el tipo de mensaje
        if let aType = aDict.objectForKey("type") as? String{
            type = aType
        }
        
        //Guardamos el contenido del mensaje
        if let aContent = aDict.objectForKey("content") as? String{
            content = aContent
        }
        
        //Guardamos la fecha de creacion
        if let fechaCreacion = aDict.objectForKey("created") as? String{
            created = fechaCreacion
        }
        
        //Guardamos el lname y fname de cada mensaje
        if let senderData = aDict.objectForKey("sender_data") as? NSDictionary{
            //Guardamos el fname
            if let aFname = senderData.objectForKey("fname") as? String{
                fname = aFname
            }
            //Guardamos el lname
            if let aLname = senderData.objectForKey("lname") as? String{
                lname = aLname
            }
        }
        
        enviado = "true"
        
        coreDataStack.saveContext()
    }
    
    
    convenience init(model:MessageModel){
        self.init(managedObjectContext:coreDataStack.context)
        messageKey = model.messageKey
        conversationKey = model.conversationKey
        sender = model.sender
        type = model.type
        content = model.content
        created = model.created
        enviado = model.enviado
        fname = model.fname
        lname = model.lname
        
        coreDataStack.saveContext()
    }
    
    //Metodo que devuelve todo el listado de Mensajes
    static func devolverListMessages(conversationKey:String) -> [MessageModel]{
        
        var listadoMessages = [MessageModel]()
        
        let request = NSFetchRequest(entityName: Messsage.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        let miShorDescriptor = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        
        for mensaje in results{
            let aux = MessageModel(modelo: mensaje)
            listadoMessages.append(aux)
        }
        return listadoMessages
    }
    
    //Borra todos los Brands
    static func borrarAllMessages() -> Bool{
        var borrado = false
        let request = NSFetchRequest(entityName: Messsage.entityName())
        request.returnsObjectsAsFaults = false
        let allMessages = try! coreDataStack.context.executeFetchRequest(request)
        
        if allMessages.count > 0 {
            
            for result: AnyObject in allMessages{
                coreDataStack.context.deleteObject(result as! Messsage)
            }
            borrado = true
        }
        
        coreDataStack.saveContext()
        return borrado
    }
    
    static func borrarMensajesConConverstaionKey(conversationKey:String){
        let request = NSFetchRequest(entityName: Messsage.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las que vamos a borrar
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        
        if messageList.count > 0 {
            
            for result: AnyObject in messageList{
                coreDataStack.context.deleteObject(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
        }
    }
    
    //Borramos todos los mensajes fallidos de una conversacion
    static func borrarMensajesFallidosConversacion(conversationKey:String){
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let conversationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las que vamos a borrar
        let enviadoPredicate = NSPredicate(format: "enviado = %@", false)//Creamos el predicate con enviado a false
        
        //Creamos un predicado con la conversationkey y enviado a false
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [conversationKeyPredicate, enviadoPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        
        if messageList.count > 0 {
            
            for result: AnyObject in messageList{
                coreDataStack.context.deleteObject(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
        }
    }
    
    //Devolvemos el ultimo mensaje y el tipo del mensaje
    static func devolverUltimoMensajeConversacion(conversationKey:String) -> MessageModel{
        
        let request = NSFetchRequest(entityName: Messsage.entityName())
        request.predicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        let miShorDescriptor = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        var conversacion = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        let message = MessageModel(modelo: conversacion[0])
        //Cambiamos el el mensaje en caso de que sea pdf, encuesta o imagen
        if(message.type == "document_pdf"){
            message.content = "📎"
        }else if(message.type == "poll" || message.type == "poll_closed"){
            message.content = "📋"
        }else if(message.type == "jpeg_base64"){
            message.content = "📷"
        }else if (message.type == "mp4_base64"){
            message.content = "📹"
        }else if (message.type == "mp4_base64"){
            message.content = "📹"
        }
        
        return message
    }
    
    //Metodo para cambiar a poll_closed una encuesta
    static func cerrarEncuesta(conversationKey:String, messageKey:String){
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = NSPredicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        if(messageList.count > 0){
            for encuesta in messageList{
                encuesta.setValue("poll_closed", forKey: "type")
                coreDataStack.saveContext()
            }
        }
    }
    
    //Metodo que se devuelve el numero de mensajes +1 para poner temporamlente de messageKey
    static func obtenerMessageKeyTemporal() -> String{
        
        let request = NSFetchRequest(entityName: Messsage.entityName())
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        
        return "\(results.count + 1)"
    }
    
    //Metodo para cambiar a poll_closed una encuesta
    static func cambiarEstadoEnviadoMensaje(conversationKey:String, messageKey:String, enviado:Bool){
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = NSPredicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        if(messageList.count > 0){
            for encuesta in messageList{
                encuesta.setValue(enviado, forKey: "enviado")
                coreDataStack.saveContext()
            }
        }
    }
    
    //Devolver los mensajes con enviado a false
    static func devolverMensajesFallidos(conversationKey:String) -> [MessageModel] {
        var listadoMessagesFallidos = [MessageModel]()
        
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)
        let enviadoPredicate = NSPredicate(format: "enviado = %@", false)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate, enviadoPredicate])
        request.predicate = andPredicate
        let miShorDescriptor = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        
        for mensaje in results{
            let aux = MessageModel(modelo: mensaje)
            listadoMessagesFallidos.append(aux)
        }
        
        return listadoMessagesFallidos
    }
    
    //Metodo para actualizar la fecha de un mensaje al reenviarlo
    static func actualizarFechaMensaje(conversationKey:String, messageKey:String, fecha:String){
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = NSPredicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        if(messageList.count > 0){
            for message in messageList{
                message.created = fecha
                coreDataStack.saveContext()
            }
        }
    }
    
    //Metodo que devuelve el ultimo mensaje enviado
    static func devolverUltimoMensajeEnviadoOk(conversationKey:String) -> MessageModel?{
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)
        let enviadoPredicate = NSPredicate(format: "enviado = %@", true)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate, enviadoPredicate])
        request.predicate = andPredicate
        let miShorDescriptor = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        var results = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        if(results.count > 0){
            let message = MessageModel(modelo: results[results.count - 1])
            //Cambiamos el el mensaje en caso de que sea pdf, encuesta o imagen
            if(message.type == "document_pdf"){
                message.content = "📎"
            }else if(message.type == "poll" || message.type == "poll_closed"){
                message.content = "📋"
            }else if(message.type == "jpeg_base64"){
                message.content = "📷"
            }else if (message.type == "mp4_base64"){
                message.content = "📹"
            }
            return message
        }else{
            return nil
        }
    }
    
    //Devuelve la hora del ultimo mensaje enviado
    static func devolverHoraUltimoMensaje(conversationKey:String) ->String {
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate])
        request.predicate = andPredicate
        let miShorDescriptor = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        var results = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        
        let message = MessageModel(modelo: results[results.count - 1])
        return message.created
    }
    
    //Metodo para cambiar el messageKeyTemporal que tenemos por el que nos devuelve el servidor
    static func updateMessageKeyTemporal(conversationKey:String, messageKey:String, messageKeyServidor:String){
        let request = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = NSPredicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = NSPredicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.executeFetchRequest(request)) as! [Messsage]
        if(messageList.count > 0){
            for encuesta in messageList{
                encuesta.setValue(messageKeyServidor, forKey: "messageKey")
                coreDataStack.saveContext()
            }
        }
    }
    
}
