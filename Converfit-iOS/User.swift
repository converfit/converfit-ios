import UIKit
import CoreData

@objc(User)
public class User: _User {

    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict:NSDictionary){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        //Guardamos el userKey
        if let anUserKey = aDict.objectForKey("user_key") as? String{
            userKey = anUserKey
        }else{
            userKey = ""
        }
        
        //Guardamos el avatar
        if let dataImage = aDict.objectForKey("user_avatar") as? String{
            if let decodedData = NSData(base64EncodedString: dataImage, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                avatar = decodedData
            }
        }
        
        if let anUserName = aDict.objectForKey("user_name") as? String{
            userName = anUserName
        }else{
            userName = ""
        }
        
        if let aLastPageTitle = aDict.objectForKey("last_page_title") as? String{
            lastPageTitle = aLastPageTitle
        }else{
            lastPageTitle = ""
        }
        
        if let aConnectionStatus = aDict.objectForKey("connection-status") as? String{
            connectionStatus = aConnectionStatus
        }else{
            connectionStatus = ""
        }
        
        if let anHoraConectado = aDict.objectForKey("last_connection") as? String{
            horaConectado = anHoraConectado
        }else{
            horaConectado = ""
        }
        
        coreDataStack.saveContext()
    }
    
    //Metodo que devuelve la lista de todos los Users
    static func devolverListaUsers() -> [UserModel]{
        var listadoUsers = [UserModel]()
        let request = NSFetchRequest(entityName: User.entityName())
        let miShorDescriptor = NSSortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [User]
        
        for user in results{
            let aux = UserModel(modelo: user)
            listadoUsers.append(aux)
        }
        return listadoUsers
    }
    
    //Metodo para buscar un User a partir de un texto dado
    static func buscarUser(textoBuscado:String) ->[UserModel]{
        var listadoUsers = [UserModel]()
        let request = NSFetchRequest(entityName: User.entityName())
        let fnamePredicate = NSPredicate(format: "userName contains[cd] %@", textoBuscado)//Obtenemos los nombres que contengan el texto
        //let lnamePredicate = NSPredicate(format: "lname contains[cd] %@", textoBuscado)//Obtenemos los nombres que contengan el texto
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let orPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [fnamePredicate])
        
        request.predicate = orPredicate
        
        let miShorDescriptor = NSSortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [User]
        
        for user in results{
            let aux = UserModel(modelo: user)
            listadoUsers.append(aux)
        }
        return listadoUsers
    }
    
    //Borra todos los User
    static func borrarAllUsers() -> Bool{
        var borrado = false
        let request = NSFetchRequest(entityName: User.entityName())
        request.returnsObjectsAsFaults = false
        let allUsers = (try! coreDataStack.context.executeFetchRequest(request)) as! [User]
        
        if allUsers.count > 0 {
            
            for result: AnyObject in allUsers{
                coreDataStack.context.deleteObject(result as! NSManagedObject)
            }
            borrado = true
            coreDataStack.saveContext()
        }
        return borrado
    }
    
    //Metodo que obtiene un User a traves del userKey
    static func obtenerUser(anUserKey:String) -> UserModel?{
        
        let request = NSFetchRequest(entityName: User.entityName())
        request.predicate = NSPredicate(format: "userKey = %@", anUserKey)
        
        var results = (try! coreDataStack.context.executeFetchRequest(request)) as! [User]
        
        if (results.count > 0){
            return UserModel(modelo: results[0])
        }else{
            return nil
        }
    }
    
}
