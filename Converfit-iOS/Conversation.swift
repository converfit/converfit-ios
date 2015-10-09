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


}
