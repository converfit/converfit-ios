import UIKit
import CoreData

@objc(User)
public class User: _User {

    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict: Dictionary<String, AnyObject>){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        //Guardamos el userKey
        userKey = aDict["user_key"] as? String ?? ""
        
        //Guardamos el avatar
        if let dataImage = aDict["user_avatar"] as? String{
            if let decodedData = Data(base64Encoded: dataImage, options: .encodingEndLineWithCarriageReturn){
                avatar = decodedData
            }
        }
        
        userName = aDict["user_name"] as? String ?? ""
        
        lastPageTitle = aDict["last_page_title"] as? String ?? ""
        
        connectionStatus = aDict["connection-status"] as? String ?? ""
        
        horaConectado = aDict["last_connection"] as? String ?? ""
        
        coreDataStack.saveContext()
    }
    
    //Metodo que devuelve el numero total de Usuarios de la APP
    static func devolverUsuariosAPP() -> [UserModel]{
        var listadoUsers = [UserModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        request.predicate = Predicate(format: "connectionStatus = %@", "mobile")//Obtenemos solo las favoritas
        let miShorDescriptor = SortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [User]
        for user in results{
            let aux = UserModel(modelo: user)
            listadoUsers.append(aux)
        }
        return listadoUsers
    }
    
    //Metodo que devuelve el numero total de Usuarios CONECTADOS
    static func devolverUsuariosConectados() -> [UserModel]{
        var listadoUsers = [UserModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        request.predicate = Predicate(format: "connectionStatus != %@", "mobile")//Obtenemos solo las favoritas
        let miShorDescriptor = SortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [User]
        for user in results{
            let aux = UserModel(modelo: user)
            listadoUsers.append(aux)
        }
        return listadoUsers
    }

    
    //Metodo para buscar un User a partir de un texto dado
    static func buscarUserConectado(_ textoBuscado:String) ->[UserModel]{
        var listadoUsers = [UserModel]()
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        let fnamePredicate = Predicate(format: "userName contains[cd] %@", textoBuscado)//Obtenemos los nombres que contengan el texto
        let conectadoPredicate = Predicate(format: "connectionStatus != %@", "mobile")//Obtenemos los nombres que contengan el texto
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let orPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [fnamePredicate, conectadoPredicate])
        
        request.predicate = orPredicate
        
        let miShorDescriptor = SortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [User]
        
        for user in results{
            let aux = UserModel(modelo: user)
            listadoUsers.append(aux)
        }
        return listadoUsers
    }
    //Metodo para buscar un User a partir de un texto dado
    static func buscarUserAPP(_ textoBuscado:String) ->[UserModel]{
        var listadoUsers = [UserModel]()
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        let fnamePredicate = Predicate(format: "userName contains[cd] %@", textoBuscado)//Obtenemos los nombres que contengan el texto
        let mobilePredicate = Predicate(format: "connectionStatus = %@", "mobile")//Obtenemos los nombres que contengan el texto
        //Creamos un predicado con las busquedas tanto del texto en el nombre como en el username
        let orPredicate = CompoundPredicate(type: CompoundPredicate.LogicalType.and, subpredicates: [fnamePredicate, mobilePredicate])
        
        request.predicate = orPredicate
        
        let miShorDescriptor = SortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [User]
        
        for user in results{
            let aux = UserModel(modelo: user)
            listadoUsers.append(aux)
        }
        return listadoUsers
    }

    
    //Borra todos los User
    static func borrarAllUsers() -> Bool{
        var borrado = false
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        request.returnsObjectsAsFaults = false
        let allUsers = (try! coreDataStack.context.fetch(request)) as! [User]
        
        if allUsers.count > 0 {
            
            for result: AnyObject in allUsers{
                coreDataStack.context.delete(result as! NSManagedObject)
            }
            borrado = true
            coreDataStack.saveContext()
        }
        return borrado
    }
    
    //Metodo que obtiene un User a traves del userKey
    static func obtenerUser(_ anUserKey:String) -> UserModel?{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        request.predicate = Predicate(format: "userKey = %@", anUserKey)
        
        var results = (try! coreDataStack.context.fetch(request)) as! [User]
        
        if results.count > 0{
            return UserModel(modelo: results[0])
        }else{
            return nil
        }
    }
    
    //Metodo que devuelve el numero total de Usuarios de la APP
    static func devolverNumeroUsuariosAPP() -> Int{
        var usuariosAPP = 0
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        request.predicate = Predicate(format: "connectionStatus = %@", "mobile")//Obtenemos solo las favoritas
        let miShorDescriptor = SortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [User]
        if results.count > 0{
            usuariosAPP = results.count
        }
        return usuariosAPP
    }
    
    //Metodo que devuelve el numero total de Usuarios CONECTADOS
    static func devolverNumeroUsuariosConectados() -> Int{
        var usuariosConectados = 0
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: User.entityName())
        request.predicate = Predicate(format: "connectionStatus != %@", "mobile")//Obtenemos solo las favoritas
        let miShorDescriptor = SortDescriptor(key: "horaConectado", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [User]
        if results.count > 0{
            usuariosConectados = results.count
        }
        
        return usuariosConectados
    }
}
