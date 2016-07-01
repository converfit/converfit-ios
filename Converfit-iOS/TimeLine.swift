import UIKit
import CoreData

@objc(TimeLine)
public class TimeLine: _TimeLine {
    
    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict: Dictionary<String, AnyObject>){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        //Guardamos el userKey
        userKey = aDict["user_key"] as? String ?? ""
        
        //Guardamos el user_avatar
        if let  dataImage = aDict["user_avatar"] as? String{
            if let decodedData = Data(base64Encoded: dataImage, options: .encodingEndLineWithCarriageReturn){
                 userAvatar = decodedData
            }
        }
        
        //Guardamos el user_name
        userName = aDict["user_name"] as? String ?? ""
        
        //Guardamos el created
        created = aDict["created"] as? String ?? ""
        
        //Guardamos el content
        content = aDict["content"] as? String ?? ""
        
        coreDataStack.saveContext()
    }

    //Metodo que devuelve todo el listado de Post
    static func devolverListTimeLine() -> [TimeLineModel]{
        
        var listadoTimeLine = [TimeLineModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: TimeLine.entityName())
        let miShorDescriptor = SortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [TimeLine]
        
        for post in results{
            let aux = TimeLineModel(modelo: post)
            listadoTimeLine.append(aux)
        }
        return listadoTimeLine
    }

    //Borramos todo el listado de Post
    static func borrarAllPost(){
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: TimeLine.entityName())
        request.returnsObjectsAsFaults = false
        let allPosts = try! coreDataStack.context.fetch(request)
        
        if allPosts.count > 0 {
            
            for result: AnyObject in allPosts{
                coreDataStack.context.delete(result as! NSManagedObject)
            }
            coreDataStack.saveContext()
        }
    }
    
    //Devolvemos los post de un userKey dado
    static func devolverPostUserKey(_ userKey:String) -> [TimeLineModel]{
        var listadoTimeLine = [TimeLineModel]()
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: TimeLine.entityName())
        request.predicate = Predicate(format: "userKey = %@", userKey)
        let miShorDescriptor = SortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.fetch(request)) as! [TimeLine]
        
        for post in results{
            let aux = TimeLineModel(modelo: post)
            listadoTimeLine.append(aux)
        }
        return listadoTimeLine
    }
}
