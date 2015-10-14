import UIKit
import CoreData

@objc(TimeLine)
public class TimeLine: _TimeLine {
    
    //Inicializador a partir del diccionario que devuelve el WS
    convenience init(aDict:NSDictionary){
        self.init(managedObjectContext:coreDataStack.context)//Llamamos al constructor padre
        
        //Guardamos el userKey
        if let anUserKey = aDict.objectForKey("user_key") as? String{
            userKey = anUserKey
        }
        
        //Guardamos el user_avatar
        if let  dataImage = aDict.objectForKey("user_avatar") as? String{
            if let decodedData = NSData(base64EncodedString: dataImage, options:NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                 userAvatar = decodedData
            }
        }
        
        //Guardamos el user_name
        if let anUserName = aDict.objectForKey("user_name") as? String{
            userName = anUserName
        }
        
        //Guardamos el created
        if let aCreated = aDict.objectForKey("created") as? String{
            created = aCreated
        }
        
        //Guardamos el content
        if let aContent = aDict.objectForKey("content") as? String{
            content = aContent
        }
        
        coreDataStack.saveContext()
    }

    //Metodo que devuelve todo el listado de Conversaciones
    static func devolverListTimeLine() -> [TimeLineModel]{
        
        var listadoTimeLine = [TimeLineModel]()
        
        let request = NSFetchRequest(entityName: Conversation.entityName())
        let miShorDescriptor = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [miShorDescriptor]
        request.returnsObjectsAsFaults = false
        
        let results = (try! coreDataStack.context.executeFetchRequest(request)) as! [TimeLine]
        
        for post in results{
            let aux = TimeLineModel(modelo: post)
            listadoTimeLine.append(aux)
        }
        return listadoTimeLine
    }

}
