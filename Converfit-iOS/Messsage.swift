import UIKit
import CoreData

@objc(Messsage)
public class Messsage: _Messsage {
    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict: Dictionary<String, AnyObject>, aConversationKey:String){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        conversationKey = aConversationKey
        //Guardamos el message key
        messageKey = aDict["message_key"] as? String ?? ""
        
        //Guardamos quien envio el mensaje
        sender = aDict["sender"] as? String ?? ""
        
        //Guardamos el tipo de mensaje
        type = aDict["type"] as? String ?? ""
        
        //Guardamos el contenido del mensaje
        content = aDict["content"] as? String ?? ""
        
        //Guardamos la fecha de creacion
        created = aDict["created"] as? String ?? ""
        
        //Guardamos el lname y fname de cada mensaje
        if let senderData = aDict["sender_data"] as? Dictionary<String, AnyObject>{
            //Guardamos el fname
            fname = senderData["fname"] as? String ?? ""
            //Guardamos el lname
            lname = senderData["lname"] as? String ?? ""
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
    static func devolverListMessages(_ conversationKey:String) -> [MessageModel]{
        
        var listadoMessages = [MessageModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        let miShorDescriptor = SortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        
        for mensaje in results{
            let aux = MessageModel(modelo: mensaje)
            listadoMessages.append(aux)
        }
        return listadoMessages
    }
    
    //Borra todos los Brands
    static func borrarAllMessages() -> Bool{
        var borrado = false
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        request.returnsObjectsAsFaults = false
        let allMessages = try! coreDataStack.context.fetch(request)
        
        if allMessages.count > 0 {
            
            for result: AnyObject in allMessages{
                coreDataStack.context.delete(result as! Messsage)
            }
            borrado = true
        }
        
        coreDataStack.saveContext()
        return borrado
    }
    
    static func borrarMensajesConConverstaionKey(_ conversationKey:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las que vamos a borrar
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        
        if messageList.count > 0 {
            
            for result: AnyObject in messageList{
                coreDataStack.context.delete(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
        }
    }
    
    //Borramos todos los mensajes fallidos de una conversacion
    static func borrarMensajesFallidosConversacion(_ conversationKey:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let conversationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las que vamos a borrar
        let enviadoPredicate = Predicate(format: "enviado = %@", false)//Creamos el predicate con enviado a false
        
        //Creamos un predicado con la conversationkey y enviado a false
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [conversationKeyPredicate, enviadoPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        
        if messageList.count > 0 {
            
            for result: AnyObject in messageList{
                coreDataStack.context.delete(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
        }
    }
    
    //Devolvemos el ultimo mensaje y el tipo del mensaje
    static func devolverUltimoMensajeConversacion(_ conversationKey:String) -> MessageModel{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        request.predicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos solo las favoritas
        let miShorDescriptor = SortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        var conversacion = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        let message = MessageModel(modelo: conversacion[0])
        //Cambiamos el el mensaje en caso de que sea pdf, encuesta o imagen
        if message.type == "document_pdf"{
            message.content = "📎"
        }else if message.type == "poll" || message.type == "poll_closed"{
            message.content = "📋"
        }else if message.type == "jpeg_base64"{
            message.content = "📷"
        }else if message.type == "mp4_base64"{
            message.content = "📹"
        }else if message.type == "mp4_base64"{
            message.content = "📹"
        }
        
        return message
    }
    
    //Metodo para cambiar a poll_closed una encuesta
    static func cerrarEncuesta(_ conversationKey:String, messageKey:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = Predicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        if messageList.count > 0{
            for encuesta in messageList{
                encuesta.setValue("poll_closed", forKey: "type")
                coreDataStack.saveContext()
            }
        }
    }
    
    //Metodo que se devuelve el numero de mensajes +1 para poner temporamlente de messageKey
    static func obtenerMessageKeyTemporal() -> String{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        
        let results = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        
        return "\(results.count + 1)"
    }
    
    //Metodo para cambiar a poll_closed una encuesta
    static func cambiarEstadoEnviadoMensaje(_ conversationKey:String, messageKey:String, enviado:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = Predicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        if messageList.count > 0{
            for encuesta in messageList{
                encuesta.setValue(enviado, forKey: "enviado")
                coreDataStack.saveContext()
            }
        }
    }
    
    //Devolver los mensajes con enviado a false
    static func devolverMensajesFallidos(_ conversationKey:String) -> [MessageModel] {
        var listadoMessagesFallidos = [MessageModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)
        let enviadoPredicate = Predicate(format: "enviado = %@", false)
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate, enviadoPredicate])
        request.predicate = andPredicate
        let miShorDescriptor = SortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        
        for mensaje in results{
            let aux = MessageModel(modelo: mensaje)
            listadoMessagesFallidos.append(aux)
        }
        
        return listadoMessagesFallidos
    }
    
    //Metodo para actualizar la fecha de un mensaje al reenviarlo
    static func actualizarFechaMensaje(_ conversationKey:String, messageKey:String, fecha:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = Predicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        if messageList.count > 0{
            for message in messageList{
                message.created = fecha
                coreDataStack.saveContext()
            }
        }
    }
    
    //Metodo que devuelve el ultimo mensaje enviado
    static func devolverUltimoMensajeEnviadoOk(_ conversationKey:String) -> MessageModel?{
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)
        let enviadoPredicate = Predicate(format: "enviado = %@", true)
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate, enviadoPredicate])
        request.predicate = andPredicate
        let miShorDescriptor = SortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        var results = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        if results.count > 0{
            let message = MessageModel(modelo: results[results.count - 1])
            //Cambiamos el el mensaje en caso de que sea pdf, encuesta o imagen
            if message.type == "document_pdf"{
                message.content = "📎"
            }else if message.type == "poll" || message.type == "poll_closed"{
                message.content = "📋"
            }else if message.type == "jpeg_base64"{
                message.content = "📷"
            }else if message.type == "mp4_base64"{
                message.content = "📹"
            }
            return message
        }else{
            return nil
        }
    }
    
    //Devuelve la hora del ultimo mensaje enviado
    static func devolverHoraUltimoMensaje(_ conversationKey:String) ->String {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate])
        request.predicate = andPredicate
        let miShorDescriptor = SortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        var results = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        
        let message = MessageModel(modelo: results[results.count - 1])
        return message.created
    }
    
    //Metodo para cambiar el messageKeyTemporal que tenemos por el que nos devuelve el servidor
    static func updateMessageKeyTemporal(_ conversationKey:String, messageKey:String, messageKeyServidor:String){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Messsage.entityName())
        let converstationKeyPredicate = Predicate(format: "conversationKey = %@", conversationKey)//Obtenemos los mensajes de una conversacion
        let messageKeyPredicate = Predicate(format: "messageKey = %@", messageKey)//Obtenemos el mensaje correspondiente a un messageKey
        
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let andPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [converstationKeyPredicate, messageKeyPredicate])
        
        request.predicate = andPredicate
        request.returnsObjectsAsFaults = false
        
        let messageList = (try! coreDataStack.context.fetch(request)) as! [Messsage]
        if messageList.count > 0{
            for encuesta in messageList{
                encuesta.setValue(messageKeyServidor, forKey: "messageKey")
                coreDataStack.saveContext()
            }
        }
    }
    
}
